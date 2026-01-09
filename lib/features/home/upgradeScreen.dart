import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';

class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  User? get _user => FirebaseAuth.instance.currentUser;

  bool loading = false;

  void _msg(String t) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  FirebaseFunctions get _functions =>
      FirebaseFunctions.instanceFor(region: "us-central1");

  Future<void> _startStripeCheckout() async {
    final l10n = AppLocalizations.of(context)!;
    final u = _user;

    if (u == null) {
      _msg(l10n.notLoggedIn);
      return;
    }

    setState(() => loading = true);

    try {
      // ✅ MUST match your exported function name in index.js
      final callable = _functions.httpsCallable(
        "createCheckoutSession",
        options: HttpsCallableOptions(timeout: const Duration(seconds: 45)),
      );

      final result = await callable.call(<String, dynamic>{
        "plan": "pro",

        // OPTIONAL: only use these if your backend uses them.
        // (Your backend already supports successUrl/cancelUrl)
        "successUrl": "kaloumo://upgrade/success?session_id={CHECKOUT_SESSION_ID}",
        "cancelUrl": "kaloumo://upgrade/cancel",
      });

      final data = result.data;
      final url = (data is Map) ? data["url"]?.toString() : null;

      if (url == null || url.isEmpty) {
        _msg(l10n.checkoutCouldNotStart);
        return;
      }

      final ok = await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );

      if (!ok) _msg(l10n.unableToOpenPaymentPage);
    } on FirebaseFunctionsException catch (e) {
      // Show real Stripe/Firebase error message
      final details = e.message ?? e.details?.toString() ?? "";
      _msg("${l10n.paymentError}: ${e.code} $details");
    } catch (e) {
      _msg("${l10n.paymentError}: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _confirmUpgrade() async {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.upgradeToProTitle),
        content: Text(l10n.upgradeToProBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel, style: TextStyle(color: colors.primary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
            ),
            child: Text(l10n.continueLabel),
          ),
        ],
      ),
    ) ??
        false;

    if (!ok) return;
    await _startStripeCheckout();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final u = _user;
    if (u == null) {
      return Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          backgroundColor: colors.surface,
          elevation: 0.3,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colors.primary),
            onPressed: () => context.pop(),
          ),
          title: Text(
            l10n.upgrade,
            style: text.titleLarge?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: Center(child: Text(l10n.notLoggedIn)),
      );
    }

    final uid = u.uid;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0.3,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.upgrade,
          style: text.titleLarge?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection("users").doc(uid).snapshots(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: colors.primary));
          }
          if (snap.hasError) {
            return Center(child: Text("${l10n.paymentError}: ${snap.error}"));
          }

          final data = snap.data?.data() ?? <String, dynamic>{};

          // ✅ Your DB truth: isPremium = true => Pro
          final isPro = data["isPremium"] == true;

          final active = (data["activeListings"] is num)
              ? (data["activeListings"] as num).toInt()
              : 0;

          final limit = (data["listingLimit"] is num)
              ? (data["listingLimit"] as num).toInt()
              : (isPro ? 50 : 3);

          return ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPro ? Icons.workspace_premium : Icons.person,
                      color: isPro ? colors.primary : colors.onSurface.withOpacity(.7),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isPro ? l10n.youAreOnPro : l10n.youAreOnFree,
                            style: text.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.activeListingsLabel(active, limit),
                            style: text.bodyMedium?.copyWith(
                              color: colors.onSurface.withOpacity(.65),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _planCard(
                      context: context,
                      title: l10n.planFreeTitle,
                      price: l10n.planFreePrice,
                      badge: l10n.planFreeBadge,
                      highlight: !isPro,
                      features: [
                        l10n.planFreeFeature1,
                        l10n.planFreeFeature2,
                        l10n.planFreeFeature3,
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _planCard(
                      context: context,
                      title: l10n.planProTitle,
                      price: l10n.planProPrice,
                      badge: l10n.planProBadge,
                      highlight: isPro,
                      features: [
                        l10n.planProFeature1,
                        l10n.planProFeature2,
                        l10n.planProFeature3,
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (loading || isPro) ? null : _confirmUpgrade,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: loading
                      ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colors.onPrimary,
                    ),
                  )
                      : Text(
                    isPro ? l10n.alreadyPro : l10n.upgradeToProButton,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.proAutoActivatesHint,
                style: text.bodySmall?.copyWith(
                  color: colors.onSurface.withOpacity(.65),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _planCard({
    required BuildContext context,
    required String title,
    required String price,
    required String badge,
    required bool highlight,
    required List<String> features,
  }) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: highlight ? colors.primary : colors.outlineVariant,
          width: highlight ? 1.6 : 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: text.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colors.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: highlight
                      ? colors.primary.withOpacity(.12)
                      : colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge,
                  style: text.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: highlight
                        ? colors.primary
                        : colors.onSurface.withOpacity(.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            price,
            style: text.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: highlight ? colors.primary : colors.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          ...features.map(
                (f) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 18,
                    color: highlight
                        ? colors.primary
                        : colors.onSurface.withOpacity(.55),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      f,
                      style: text.bodySmall?.copyWith(
                        color: colors.onSurface.withOpacity(.75),
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
