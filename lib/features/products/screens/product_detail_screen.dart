// ==============================
// ProductDetailScreen (LOCALIZED)
// ==============================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../../core/services/chat_service.dart';
import '../../../core/services/favorite_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/product_service.dart';
import '../../../models/product_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final service = ProductService();
  final favService = FavoriteService();
  final chatService = ChatService();

  bool startingChat = false;

  String sellerRoute(String sellerId) => '/seller/$sellerId';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0.3,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.productDetailsTitle,
          style: text.titleLarge?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          StreamBuilder<bool>(
            stream: favService.favoriteStream(widget.productId),
            builder: (context, snap) {
              final isFav = snap.data == true;
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: colors.primary,
                ),
                onPressed: () async {
                  if (isFav) {
                    await favService.removeFavorite(widget.productId);
                  } else {
                    await favService.addFavorite(widget.productId);
                  }
                },
              );
            },
          ),
        ],
      ),

      body: StreamBuilder<ProductModel>(
        stream: service.getProductById(widget.productId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: colors.primary));
          }

          if (snap.hasError) {
            return Center(child: Text(l10n.failedToLoadProduct));
          }

          if (!snap.hasData) {
            return Center(child: Text(l10n.productNotFound));
          }

          final p = snap.data!;
          final isOwner = p.ownerId == uid;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ================= IMAGES =================
                CarouselSlider(
                  items: p.images.map((img) {
                    return Image.network(
                      img,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    );
                  }).toList(),
                  options: CarouselOptions(
                    height: 300,
                    viewportFraction: 1,
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ================= TITLE =================
                      Text(
                        p.title,
                        style: text.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      /// ================= PRICE + SOLD =================
                      Row(
                        children: [
                          Text(
                            "GNF ${p.price}",
                            style: text.headlineSmall?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (p.isSold)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: colors.error.withOpacity(.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                l10n.soldUnavailable,
                                style: TextStyle(
                                  color: colors.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      /// ================= LOCATION + CONDITION =================
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              color: colors.primary, size: 20),
                          const SizedBox(width: 6),
                          Expanded(child: Text(p.location)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              p.condition,
                              style: text.bodySmall?.copyWith(
                                color: colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      /// ================= DESCRIPTION =================
                      Text(
                        l10n.descriptionTitle,
                        style: text.titleMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(p.description),

                      const SizedBox(height: 24),

                      /// ================= SELLER =================
                      Text(
                        l10n.sellerTitle,
                        style: text.titleMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      _SellerCard(
                        sellerId: p.ownerId,
                        onOpenProfile: () =>
                            context.push(sellerRoute(p.ownerId)),
                      ),

                      const SizedBox(height: 26),

                      /// ================= OWNER ACTION =================
                      if (isOwner && !p.isSold)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.check_circle),
                            label: Text(l10n.markAsSold),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text(l10n.markAsSoldTitle),
                                  content: Text(l10n.markAsSoldBody),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: Text(l10n.cancel),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: Text(l10n.markAsSold),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await service.markAsSold(p.id);
                              }
                            },
                          ),
                        ),

                      const SizedBox(height: 16),

                      /// ================= CHAT BUTTON =================
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: (p.isSold || startingChat)
                              ? null
                              : () async {
                            setState(() => startingChat = true);
                            try {
                              final chatId =
                              await chatService.startChat(
                                productId: p.id,
                                sellerId: p.ownerId,
                              );
                              if (!mounted) return;
                              context.push('/chat/$chatId');
                            } finally {
                              if (mounted) {
                                setState(() => startingChat = false);
                              }
                            }
                          },
                          icon: Icon(
                            p.isSold ? Icons.lock : Icons.chat,
                            color: colors.onPrimary,
                          ),
                          label: Text(
                            p.isSold
                                ? l10n.productSold
                                : startingChat
                                ? l10n.openingChat
                                : l10n.chatWithSeller,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            p.isSold ? colors.surfaceVariant : colors.primary,
                            foregroundColor:
                            p.isSold ? colors.onSurface : colors.onPrimary,
                            padding:
                            const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// ==============================
/// Seller Card
/// ==============================
class _SellerCard extends StatelessWidget {
  final String sellerId;
  final VoidCallback onOpenProfile;

  const _SellerCard({
    required this.sellerId,
    required this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(sellerId)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Padding(
            padding: const EdgeInsets.all(14),
            child: Text(l10n.loadingSeller),
          );
        }

        final data = snap.data!.data() ?? {};
        final sellerName =
        (data['name'] ?? l10n.sellerFallback).toString();
        final location = (data['location'] ?? '').toString();

        return InkWell(
          onTap: onOpenProfile,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: colors.primary.withOpacity(.2),
                  child: Icon(Icons.person, color: colors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sellerName,
                        style: text.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (location.isNotEmpty)
                        Text(
                          location,
                          style: text.bodySmall?.copyWith(
                            color: colors.onSurface.withOpacity(.6),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.tapToViewProfile,
                        style: text.bodySmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right,
                    color: colors.onSurfaceVariant),
              ],
            ),
          ),
        );
      },
    );
  }
}
