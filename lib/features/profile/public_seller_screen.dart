import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';

class PublicSellerScreen extends StatelessWidget {
  final String sellerId;

  const PublicSellerScreen({
    super.key,
    required this.sellerId,
  });

  String _formatPrice(dynamic value) {
    if (value == null) return "—";
    final num? n = value is num ? value : num.tryParse(value.toString());
    if (n == null) return value.toString();

    final s = n.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final posFromEnd = s.length - i;
      buf.write(s[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buf.write(' ');
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0.3,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.sellerProfileTitle,
          style: text.titleLarge?.copyWith(color: colors.onBackground),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance.collection('users').doc(sellerId).get(),
        builder: (context, userSnap) {
          if (userSnap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: colors.primary));
          }

          if (!userSnap.hasData || !userSnap.data!.exists) {
            return Center(child: Text(l10n.sellerNotFound));
          }

          final user = userSnap.data!.data() ?? {};

          // ===========================
          // SAFE DATABASE READS
          // ===========================
          final String name = (user['name'] is String && (user['name'] as String).trim().isNotEmpty)
              ? (user['name'] as String)
              : l10n.sellerFallback;

          final String photoUrl = (user['photoUrl'] is String) ? (user['photoUrl'] as String) : '';

          final String location = (user['location'] is String) ? (user['location'] as String) : '';

          final double rating = (user['rating'] is num) ? (user['rating'] as num).toDouble() : 0.0;

          final int ratingCount = (user['ratingCount'] is num) ? (user['ratingCount'] as num).toInt() : 0;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===========================
              // SELLER HEADER CARD
              // ===========================
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.outlineVariant.withOpacity(.5)),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow.withOpacity(.12),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: colors.primary.withOpacity(.2),
                      backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                      child: photoUrl.isEmpty ? Icon(Icons.person, size: 36, color: colors.primary) : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),

                          Text(
                            l10n.sellerRatingLabel,
                            style: text.bodySmall?.copyWith(
                              color: colors.onSurface.withOpacity(.55),
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                rating.toStringAsFixed(1),
                                style: text.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.onSurface,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "($ratingCount)",
                                style: text.bodySmall?.copyWith(
                                  color: colors.onSurface.withOpacity(.6),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          if (location.trim().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 16, color: colors.primary),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    location,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: text.bodySmall?.copyWith(
                                      color: colors.onSurface.withOpacity(.7),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  l10n.listingsTitle,
                  style: text.titleMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ===========================
              // SELLER PRODUCTS GRID
              // ===========================
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('products')
                      .where('ownerId', isEqualTo: sellerId)
                  // optional: show newest first if you store createdAt
                  // .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: colors.primary));
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text(l10n.failedToLoadProducts));
                    }

                    final docs = snapshot.data?.docs ?? [];

                    if (docs.isEmpty) {
                      return Center(
                        child: Text(
                          l10n.noProductsFromSeller,
                          style: text.bodyMedium?.copyWith(color: colors.onSurface),
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.76,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data();

                        final List images = (data['images'] is List) ? (data['images'] as List) : [];
                        final String? image = images.isNotEmpty ? images.first.toString() : null;

                        final String title = (data['title'] ?? '').toString();
                        final String price = _formatPrice(data['price']);
                        final bool isSold = data['isSold'] == true;

                        return InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => context.push('/product/${doc.id}'),
                          child: Container(
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: colors.outlineVariant.withOpacity(.5)),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.shadow.withOpacity(.10),
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 130,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      image != null
                                          ? Image.network(image, fit: BoxFit.cover)
                                          : Container(
                                        color: colors.surfaceVariant,
                                        child: Icon(Icons.image_not_supported, color: colors.onSurfaceVariant),
                                      ),

                                      if (isSold)
                                        Positioned.fill(
                                          child: Container(
                                            color: Colors.black.withOpacity(.45),
                                            alignment: Alignment.center,
                                            child: Text(
                                              l10n.soldLabel,
                                              style: text.titleMedium?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title.isEmpty ? l10n.productFallback : title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: text.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "GNF $price",
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
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
