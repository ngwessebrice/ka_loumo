import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/services/favorite_service.dart';
import '../../l10n/app_localizations.dart';
import '../../models/product_model.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final favService = FavoriteService();

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
          l10n.favoritesTitle,
          style: text.titleLarge?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: StreamBuilder<List<String>>(
        stream: favService.getFavoriteIds(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: colors.primary));
          }

          if (snap.hasError) {
            return Center(child: Text(l10n.failedToLoadFavorites));
          }

          final favIds = snap.data ?? [];
          if (favIds.isEmpty) return const _EmptyFavorites();

          // ✅ IMPORTANT:
          // If your products docId == productId, it's better to query by documentId instead of a field "id".
          // Keep "id" if your schema truly stores products with an "id" field.
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('products')
                .where(FieldPath.documentId, whereIn: favIds.take(10).toList())
                .snapshots(),
            builder: (context, prodSnap) {
              if (prodSnap.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: colors.primary));
              }

              if (prodSnap.hasError) {
                return Center(child: Text(l10n.failedToLoadProducts));
              }

              final docs = prodSnap.data?.docs ?? [];
              if (docs.isEmpty) return const _EmptyFavorites();

              // If you can have >10 favorites, fetch in batches or store favorites as subcollection.
              final products = docs.map((d) {
                final data = d.data() as Map<String, dynamic>;

                return ProductModel(
                  id: d.id,
                  title: (data['title'] ?? '').toString(),
                  description: (data['description'] ?? '').toString(),
                  price: (data['price'] is num) ? (data['price'] as num).toInt() : 0,
                  category: (data['category'] ?? '').toString(),
                  images: List<String>.from((data['images'] as List?) ?? const []),
                  ownerId: (data['ownerId'] ?? '').toString(),
                  location: (data['location'] ?? '').toString(),
                  condition: (data['condition'] ?? '').toString(),
                  createdBy: (data['createdBy'] ?? '').toString(),
                  createdAt: (data['createdAt'] is Timestamp)
                      ? (data['createdAt'] as Timestamp).toDate()
                      : DateTime.now(),
                  isSold: data['isSold'] == true,
                );
              }).toList();

              // Keep grid stable (optional): sort by createdAt desc
              products.sort((a, b) => b.createdAt.compareTo(a.createdAt));

              return Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (context, index) {
                    return _FavoriteCard(product: products[index]);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// -------------------------------------------------------
// 🖤 EMPTY STATE — localized
// -------------------------------------------------------

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border,
              size: 90, color: colors.primary.withOpacity(0.85)),
          const SizedBox(height: 16),
          Text(
            l10n.favoritesEmptyTitle,
            style: text.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.favoritesEmptySubtitle,
            style: text.bodyMedium?.copyWith(
              color: colors.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------
// 🟨 FAVORITE PRODUCT CARD — localized + safe image
// -------------------------------------------------------

class _FavoriteCard extends StatelessWidget {
  final ProductModel product;
  const _FavoriteCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final cover = product.images.isNotEmpty ? product.images.first : null;

    return GestureDetector(
      onTap: () => context.push('/product/${product.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: cover != null
                  ? Image.network(
                cover,
                height: 135,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 135,
                  color: colors.surface,
                  child: Icon(Icons.broken_image, color: colors.primary),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: 135,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      color: colors.primary,
                      strokeWidth: 2,
                    ),
                  );
                },
              )
                  : Container(
                height: 135,
                width: double.infinity,
                color: colors.surface,
                child: Icon(Icons.image, color: colors.primary),
              ),
            ),

            // Product Text
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "GNF ${product.price}",
                    style: text.bodyMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
