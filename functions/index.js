/**
 * functions/index.js (Firebase Functions v2 / Gen2, Node 20)
 * Stripe Checkout + Webhook (RAW body)
 * Plans: free / pro
 *
 * ✅ Uses Firebase Secrets for Stripe keys
 * ✅ Webhook uses RAW body for Stripe signature verification
 * ✅ Fixes Stripe "internal error" by using HTTPS success/cancel URLs
 * ✅ Upgrades/downgrades Firestore user plan via webhook events
 */

const admin = require("firebase-admin");
admin.initializeApp();

const Stripe = require("stripe");
const express = require("express");

const { onCall, onRequest } = require("firebase-functions/v2/https");
const { defineString, defineSecret } = require("firebase-functions/params");

// -------------------------
// Runtime Params (non-secret)
// -------------------------
const STRIPE_PRO_PRICE_ID = defineString("STRIPE_PRO_PRICE_ID");

// MUST be HTTPS (Stripe redirects)
// Example:
// CHECKOUT_SUCCESS_URL="https://kaloumo.app/stripe/success?session_id={CHECKOUT_SESSION_ID}"
// CHECKOUT_CANCEL_URL="https://kaloumo.app/stripe/cancel"
const CHECKOUT_SUCCESS_URL = defineString("CHECKOUT_SUCCESS_URL");
const CHECKOUT_CANCEL_URL = defineString("CHECKOUT_CANCEL_URL");

// -------------------------
// Secrets (Firebase Secrets)
// -------------------------
const STRIPE_SECRET_KEY = defineSecret("STRIPE_SECRET_KEY_SECRET");
const STRIPE_WEBHOOK_SECRET = defineSecret("STRIPE_WEBHOOK_SECRET_SECRET");

// -------------------------
// Stripe client
// -------------------------
function getStripe() {
  const key = process.env.STRIPE_SECRET_KEY_SECRET;
  if (!key) throw new Error("Missing STRIPE_SECRET_KEY_SECRET");
  return new Stripe(key, { apiVersion: "2023-10-16" });
}

// -------------------------
// Plan helpers (FREE / PRO)
// -------------------------
function planConfig(plan) {
  if (plan === "pro") return { plan: "pro", listingLimit: 50, isPremium: true };
  return { plan: "free", listingLimit: 3, isPremium: false };
}

async function setUserPlan(uid, plan, stripeData = {}) {
  const cfg = planConfig(plan);

  const update = {
    plan: cfg.plan,
    listingLimit: cfg.listingLimit,
    isPremium: cfg.isPremium,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  };

  // timestamps
  if (plan === "pro") {
    update.proSince = admin.firestore.FieldValue.serverTimestamp();
  } else {
    update.proSince = admin.firestore.FieldValue.delete();
  }

  // Keep customerId if provided (do not delete if missing)
  if (stripeData.customerId) update.stripeCustomerId = stripeData.customerId;

  // Keep subscriptionId only for PRO
  if (plan === "pro" && stripeData.subscriptionId) {
    update.stripeSubscriptionId = stripeData.subscriptionId;
  }
  if (plan !== "pro") {
    update.stripeSubscriptionId = admin.firestore.FieldValue.delete();
  }

  await admin.firestore().collection("users").doc(uid).set(update, { merge: true });
}

// -------------------------
// Idempotency (Stripe retries)
// -------------------------
async function alreadyProcessed(eventId) {
  const ref = admin.firestore().collection("_stripe_events").doc(eventId);
  const snap = await ref.get();
  if (snap.exists) return true;
  await ref.set({ processedAt: admin.firestore.FieldValue.serverTimestamp() });
  return false;
}

// ============================================================
// 1) Callable: Create Checkout Session (Subscription) - PRO only
// ============================================================
exports.createCheckoutSession = onCall(
  {
    region: "us-central1",
    secrets: [STRIPE_SECRET_KEY],
  },
  async (request) => {
    if (!request.auth) throw new Error("unauthenticated: Login required.");

    const stripe = getStripe();
    const uid = request.auth.uid;

    const proPrice = STRIPE_PRO_PRICE_ID.value();
    if (!proPrice) throw new Error("Missing STRIPE_PRO_PRICE_ID");

    const userRef = admin.firestore().collection("users").doc(uid);
    const userSnap = await userRef.get();
    const user = userSnap.data() || {};

    // Create/reuse Stripe customer
    let customerId = user.stripeCustomerId;
    if (!customerId) {
      const customer = await stripe.customers.create({ metadata: { uid } });
      customerId = customer.id;
      await userRef.set({ stripeCustomerId: customerId }, { merge: true });
    }

    const data = request.data || {};

    // ✅ Stripe needs HTTPS redirect URLs (NOT kaloumo://)
    const defaultSuccess =
      "https://kaloumo.app/stripe/success?session_id={CHECKOUT_SESSION_ID}";
    const defaultCancel = "https://kaloumo.app/stripe/cancel";

    const successUrl =
      data.successUrl || CHECKOUT_SUCCESS_URL.value() || defaultSuccess;
    const cancelUrl =
      data.cancelUrl || CHECKOUT_CANCEL_URL.value() || defaultCancel;

    const session = await stripe.checkout.sessions.create({
      mode: "subscription",
      customer: customerId,
      line_items: [{ price: proPrice, quantity: 1 }],
      success_url: successUrl,
      cancel_url: cancelUrl,

      // Helps mapping on webhook
      metadata: { uid, chosenPlan: "pro" },
    });

    return { url: session.url };
  }
);

// ============================================================
// 2) Webhook: Stripe events (RAW body)
// ============================================================
const webhookApp = express();

webhookApp.post("/", express.raw({ type: "application/json" }), async (req, res) => {
  const stripe = getStripe();

  const whSecret = process.env.STRIPE_WEBHOOK_SECRET_SECRET;
  if (!whSecret) return res.status(500).send("Missing STRIPE_WEBHOOK_SECRET_SECRET");

  const sig = req.headers["stripe-signature"];
  if (!sig) return res.status(400).send("Missing Stripe-Signature");

  let event;
  try {
    event = stripe.webhooks.constructEvent(req.body, sig, whSecret);
  } catch (err) {
    console.error("❌ Signature verification failed:", err.message);
    return res.status(400).send("Invalid signature");
  }

  console.log("✅ Stripe webhook received:", event.type, "id:", event.id);

  try {
    // idempotency
    if (await alreadyProcessed(event.id)) {
      console.log("↩️ Duplicate event ignored:", event.id);
      return res.status(200).json({ received: true, duplicate: true });
    }

    // -------------------------
    // PRO activate (checkout complete)
    // -------------------------
    if (event.type === "checkout.session.completed") {
      const session = event.data.object;

      const uid = session?.metadata?.uid;
      const customerId = session?.customer || null;
      const subscriptionId = session?.subscription || null;

      if (uid) {
        await setUserPlan(uid, "pro", { customerId, subscriptionId });
        console.log("✅ Upgraded to PRO (by uid):", uid);
      } else if (customerId) {
        // fallback: find user by stripeCustomerId
        const q = await admin
          .firestore()
          .collection("users")
          .where("stripeCustomerId", "==", customerId)
          .limit(1)
          .get();

        if (!q.empty) {
          const foundUid = q.docs[0].id;
          await setUserPlan(foundUid, "pro", { customerId, subscriptionId });
          console.log("✅ Upgraded to PRO (by customerId):", foundUid);
        } else {
          console.warn("⚠️ No user found for stripeCustomerId:", customerId);
        }
      }
    }

    // -------------------------
    // Best reliability: invoice paid => ensure PRO
    // -------------------------
    if (event.type === "invoice.payment_succeeded") {
      const invoice = event.data.object;
      const customerId = invoice?.customer || null;
      const subscriptionId = invoice?.subscription || null;

      let uid = null;

      if (subscriptionId) {
        const q1 = await admin
          .firestore()
          .collection("users")
          .where("stripeSubscriptionId", "==", subscriptionId)
          .limit(1)
          .get();
        if (!q1.empty) uid = q1.docs[0].id;
      }

      if (!uid && customerId) {
        const q2 = await admin
          .firestore()
          .collection("users")
          .where("stripeCustomerId", "==", customerId)
          .limit(1)
          .get();
        if (!q2.empty) uid = q2.docs[0].id;
      }

      if (uid) {
        await setUserPlan(uid, "pro", { customerId, subscriptionId });
        console.log("✅ Ensured PRO (invoice.payment_succeeded):", uid);
      } else {
        console.warn("⚠️ No user found for invoice.payment_succeeded", {
          customerId,
          subscriptionId,
        });
      }
    }

    // -------------------------
    // Downgrade to FREE (subscription deleted)
    // -------------------------
    if (event.type === "customer.subscription.deleted") {
      const sub = event.data.object;
      const subscriptionId = sub?.id || null;
      const customerId = sub?.customer || null;

      let q = null;

      if (subscriptionId) {
        q = await admin
          .firestore()
          .collection("users")
          .where("stripeSubscriptionId", "==", subscriptionId)
          .limit(1)
          .get();
      }

      if ((!q || q.empty) && customerId) {
        q = await admin
          .firestore()
          .collection("users")
          .where("stripeCustomerId", "==", customerId)
          .limit(1)
          .get();
      }

      if (q && !q.empty) {
        const uid = q.docs[0].id;
        await setUserPlan(uid, "free", { customerId });
        console.log("⬇️ Downgraded to FREE:", uid);
      } else {
        console.warn("⚠️ No user found for subscription.deleted:", {
          customerId,
          subscriptionId,
        });
      }
    }

    return res.status(200).json({ received: true });
  } catch (e) {
    console.error("❌ Webhook handler error:", e);
    return res.status(500).send("Webhook handler failed");
  }
});

// Export webhook function (Gen2)
exports.stripeWebhook = onRequest(
  {
    region: "us-central1",
    cors: false,
    secrets: [STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET],
  },
  webhookApp
);
