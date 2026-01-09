import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/chat_service.dart';
import '../../../l10n/app_localizations.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  const ChatScreen({super.key, required this.chatId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final chatService = ChatService();
  final controller = TextEditingController();
  final uid = FirebaseAuth.instance.currentUser!.uid;

  bool isSold = false; // 🔒 chat locked when sold
  bool _soldStateInitialized = false; // 🛡 prevents rebuild spam

  bool _ratingDialogShown = false; // ⭐ show rating popup once per screen open

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _showMsg(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ============================
  // ✅ SELLER: MARK DEAL COMPLETED + SOLD + DECREMENT activeListings
  // ============================
  Future<void> _markAsCompleted({
    required String chatId,
    required String productId,
    required String sellerId,
  }) async {
    final colors = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Complete deal?"),
        content: const Text(
          "Mark this deal as completed and sold?\nThe buyer will be able to rate you.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel", style: TextStyle(color: colors.primary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Confirm"),
          ),
        ],
      ),
    ) ??
        false;

    if (!confirmed) return;

    final db = FirebaseFirestore.instance;
    final chatRef = db.collection('chats').doc(chatId);
    final productRef = db.collection('products').doc(productId);
    final sellerRef = db.collection('users').doc(sellerId);

    try {
      await db.runTransaction((tx) async {
        final chatSnap = await tx.get(chatRef);
        final chat = chatSnap.data() as Map<String, dynamic>? ?? {};

        final alreadyProcessed = chat['soldProcessed'] == true;

        tx.set(
          chatRef,
          {
            'status': 'completed',
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        tx.set(
          productRef,
          {
            'isSold': true,
            'status': 'sold',
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        if (!alreadyProcessed) {
          tx.set(
            sellerRef,
            {
              'activeListings': FieldValue.increment(-1),
              'updatedAt': FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );

          tx.set(
            chatRef,
            {'soldProcessed': true},
            SetOptions(merge: true),
          );
        }
      });

      _showMsg("Deal marked completed & sold ✅");
    } catch (e) {
      _showMsg("Failed: $e");
    }
  }

  // ============================
  // ⭐ RATING POPUP (BUYER ONLY)
  // ============================
  void _maybePromptRating(Map<String, dynamic> chat) {
    final sellerId = (chat['sellerId'] ?? '').toString();
    final status = (chat['status'] ?? 'active').toString();
    final rated = chat['rated'] == true;

    final shouldPrompt =
        status == 'completed' && !rated && sellerId.isNotEmpty && uid != sellerId;

    if (!shouldPrompt) return;
    if (_ratingDialogShown) return;

    _ratingDialogShown = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showRateSellerDialog(
        chatId: widget.chatId,
        sellerId: sellerId,
        productId: (chat['productId'] ?? '').toString(),
      );
    });
  }

  Future<void> _showRateSellerDialog({
    required String chatId,
    required String sellerId,
    required String productId,
  }) async {
    int selected = 5;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        final colors = Theme.of(context).colorScheme;
        final text = Theme.of(context).textTheme;

        return StatefulBuilder(
          builder: (context, setLocal) {
            return AlertDialog(
              title: Text(
                "Rate the seller",
                style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "How's your experience?",
                    style: text.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 2,
                    children: List.generate(5, (i) {
                      final star = i + 1;
                      final filled = star <= selected;
                      return IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints:
                        const BoxConstraints(minWidth: 40, minHeight: 40),
                        onPressed: () => setLocal(() => selected = star),
                        icon: Icon(
                          filled ? Icons.star : Icons.star_border,
                          color: filled
                              ? colors.primary
                              : colors.onSurface.withOpacity(.45),
                          size: 28,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "You can rate only once for this chat.",
                    style: text.bodySmall?.copyWith(
                      color: colors.onSurface.withOpacity(.55),
                    ),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Later",
                    style: TextStyle(
                      color: colors.onSurface.withOpacity(.7),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _submitRating(
                        chatId: chatId,
                        sellerId: sellerId,
                        productId: productId,
                        rating: selected,
                      );
                      if (!mounted) return;
                      Navigator.pop(context);
                      _showMsg("Thanks for your rating!");
                    } catch (e) {
                      if (!mounted) return;
                      Navigator.pop(context);
                      _showMsg("Rating failed: $e");
                      _ratingDialogShown = false;
                    }
                  },
                  child: const Text("Submit"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitRating({
    required String chatId,
    required String sellerId,
    required String productId,
    required int rating,
  }) async {
    final buyerId = uid;
    final db = FirebaseFirestore.instance;

    final chatRef = db.collection('chats').doc(chatId);
    final chatSnap = await chatRef.get();
    final chatData = chatSnap.data() as Map<String, dynamic>? ?? {};
    if (chatData['rated'] == true) return;

    await db.collection('reviews').doc(chatId).set({
      'chatId': chatId,
      'productId': productId,
      'sellerId': sellerId,
      'buyerId': buyerId,
      'rating': rating,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: false));

    await db.runTransaction((tx) async {
      final userRef = db.collection('users').doc(sellerId);
      final userSnap = await tx.get(userRef);

      final data = userSnap.data() as Map<String, dynamic>? ?? {};
      final oldRating =
      (data['rating'] is num) ? (data['rating'] as num).toDouble() : 0.0;
      final oldCount =
      (data['ratingCount'] is num) ? (data['ratingCount'] as num).toInt() : 0;

      final newCount = oldCount + 1;
      final newRating = ((oldRating * oldCount) + rating) / newCount;

      tx.set(
        userRef,
        {
          'rating': double.parse(newRating.toStringAsFixed(2)),
          'ratingCount': newCount,
        },
        SetOptions(merge: true),
      );

      tx.update(chatRef, {'rated': true});
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId)
          .snapshots(),
      builder: (context, chatSnap) {
        if (!chatSnap.hasData || !chatSnap.data!.exists) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final chat = chatSnap.data!.data() as Map<String, dynamic>;

        _maybePromptRating(chat);

        final productId = (chat['productId'] ?? '').toString();
        final sellerId = (chat['sellerId'] ?? '').toString();
        final status = (chat['status'] ?? 'active').toString();

        final isSeller = sellerId.isNotEmpty && uid == sellerId;
        final canMarkCompleted = isSeller && status == 'active';

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.chat),
            elevation: 0.3,
            actions: [
              if (canMarkCompleted)
                IconButton(
                  tooltip: l10n.markAsSold, // closest existing label
                  icon: const Icon(Icons.check_circle_outline),
                  onPressed: () => _markAsCompleted(
                    chatId: widget.chatId,
                    productId: productId,
                    sellerId: sellerId,
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              /// ======================
              /// PRODUCT BADGE (TOP)
              /// ======================
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('products')
                    .doc(productId)
                    .get(),
                builder: (context, productSnap) {
                  if (!productSnap.hasData || !productSnap.data!.exists) {
                    return const SizedBox();
                  }

                  final product =
                  productSnap.data!.data() as Map<String, dynamic>;
                  final sold = product['isSold'] == true;

                  if (!_soldStateInitialized || sold != isSold) {
                    _soldStateInitialized = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;
                      setState(() => isSold = sold);
                      if (sold) FocusScope.of(context).unfocus();
                    });
                  }

                  final images = (product['images'] as List?) ?? [];
                  final image = images.isNotEmpty ? images.first : null;

                  return InkWell(
                    onTap: () => context.push('/product/$productId'),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.surfaceVariant,
                        border: Border(
                          bottom: BorderSide(
                            color: colors.outline.withOpacity(.2),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: image != null
                                ? Image.network(
                              image,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                            )
                                : Container(
                              width: 52,
                              height: 52,
                              color: colors.surface,
                              child: Icon(Icons.image,
                                  color: colors.primary),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  (product['title'] ?? l10n.productFallback)
                                      .toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "GNF ${product['price'] ?? ''}",
                                  style: TextStyle(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (sold)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 4),
                                    child: Text(
                                      "SOLD",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              color: colors.onSurface.withOpacity(.4)),
                        ],
                      ),
                    ),
                  );
                },
              ),

              /// ======================
              /// MESSAGES
              /// ======================
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: chatService.getMessages(widget.chatId),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snap.data!.docs;

                    if (docs.isEmpty) {
                      return Center(child: Text(l10n.noMessagesYet));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final msg = docs[i];
                        final isMe = msg['senderId'] == uid;

                        return Align(
                          alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? colors.primary
                                  : colors.surfaceVariant,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              (msg['text'] ?? '').toString(),
                              style: TextStyle(
                                color: isMe
                                    ? colors.onPrimary
                                    : colors.onSurface,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              /// ======================
              /// INPUT (LOCKED WHEN SOLD)
              /// ======================
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          enabled: !isSold,
                          decoration: InputDecoration(
                            hintText: isSold
                                ? "Product sold — chat closed"
                                : l10n.typeMessage,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.send,
                          color: isSold ? colors.outline : colors.primary,
                        ),
                        onPressed: isSold
                            ? null
                            : () async {
                          if (controller.text.trim().isEmpty) return;

                          await chatService.sendMessage(
                            chatId: widget.chatId,
                            text: controller.text.trim(),
                          );

                          controller.clear();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
