import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../l10n/app_localizations.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  DateTime _asDate(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
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
            l10n.myListingsTitle,
            style: text.titleLarge?.copyWith(color: colors.onBackground),
          ),
        ),
        body: Center(child: Text(l10n.userNotLoggedIn)),
      );
    }

    final uid = user.uid;

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
          l10n.myListingsTitle,
          style: text.titleLarge?.copyWith(color: colors.onBackground),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('ownerId', isEqualTo: uid)
        // ✅ NO orderBy => no composite index needed
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.failedToLoadListings,
                  style: text.bodySmall?.copyWith(color: colors.error),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colors.primary),
            );
          }

          final docs = (snapshot.data?.docs ?? []).toList();

          // ✅ Sort locally by createdAt (newest first)
          docs.sort((a, b) {
            final ad = a.data() as Map<String, dynamic>? ?? {};
            final bd = b.data() as Map<String, dynamic>? ?? {};
            final aDate = _asDate(ad['createdAt']);
            final bDate = _asDate(bd['createdAt']);
            return bDate.compareTo(aDate);
          });

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 70,
                    color: colors.onSurface.withOpacity(.4),
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.noListingsYet, style: text.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    l10n.listingsEmptySubtitle,
                    style: text.bodySmall?.copyWith(
                      color: colors.onSurface.withOpacity(.6),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final productId = docs[index].id;

              return _ListingCard(
                data: data,
                productId: productId,
              );
            },
          );
        },
      ),
    );
  }
}

class _ListingCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final String productId;

  const _ListingCard({
    required this.data,
    required this.productId,
  });

  @override
  State<_ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<_ListingCard> {
  bool _deleting = false;

  void _toast(BuildContext context, String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _deleteListing(BuildContext context) async {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteProductTitle),
        content: Text(l10n.deleteProductBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel, style: TextStyle(color: colors.primary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.delete,
              style: TextStyle(color: colors.error),
            ),
          ),
        ],
      ),
    ) ??
        false;

    if (!confirm) return;

    setState(() => _deleting = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        _toast(context, l10n.userNotLoggedIn);
        return;
      }

      final db = FirebaseFirestore.instance;
      final productRef = db.collection("products").doc(widget.productId);
      final userRef = db.collection("users").doc(uid);

      // ✅ Robust transaction (will not fail if user doc doesn't exist)
      await db.runTransaction((tx) async {
        final productSnap = await tx.get(productRef);
        if (!productSnap.exists) return;

        final p = productSnap.data() as Map<String, dynamic>? ?? {};
        final ownerId = (p["ownerId"] ?? "").toString().trim();
        final isSold = p["isSold"] == true;

        // ✅ Must be owner
        if (ownerId.isEmpty || ownerId != uid) {
          throw FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
            message: 'Not owner of product',
          );
        }

        // ✅ If product is active (not sold) decrement activeListings
        // Use set(merge:true) so it never fails if user doc missing
        if (!isSold) {
          tx.set(
            userRef,
            {
              "activeListings": FieldValue.increment(-1),
              "updatedAt": FieldValue.serverTimestamp(),
            },
            SetOptions(merge: true),
          );
        } else {
          tx.set(
            userRef,
            {"updatedAt": FieldValue.serverTimestamp()},
            SetOptions(merge: true),
          );
        }

        // ✅ delete product
        tx.delete(productRef);
      });

      if (!mounted) return;
      _toast(context, l10n.listingDeletedSuccess);
    } on FirebaseException catch (e) {
      if (!mounted) return;
      // ✅ show exact error
      _toast(context, "${l10n.deleteFailed}: ${e.code} ${e.message ?? ''}");
    } catch (e) {
      if (!mounted) return;
      _toast(context, "${l10n.deleteFailed}: $e");
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    final data = widget.data;
    final List images = (data['images'] as List?) ?? [];

    final title = (data['title'] ?? '').toString();
    final price = (data['price'] ?? '').toString();
    final condition = (data['condition'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withOpacity(.6)),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: images.isNotEmpty
              ? Image.network(
            images.first.toString(),
            width: 55,
            height: 55,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 55,
              height: 55,
              color: colors.surfaceVariant,
              child: Icon(
                Icons.broken_image,
                color: colors.onSurface.withOpacity(.6),
              ),
            ),
          )
              : Container(
            width: 55,
            height: 55,
            color: colors.surfaceVariant,
            child: Icon(
              Icons.image_not_supported,
              color: colors.onSurface.withOpacity(.6),
            ),
          ),
        ),
        title: Text(
          title,
          style: text.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "$price • $condition",
          style: text.bodySmall?.copyWith(
            color: colors.onSurface.withOpacity(.6),
          ),
        ),
        trailing: _deleting
            ? SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: colors.primary,
          ),
        )
            : PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: colors.onSurface),
          onSelected: (value) async {
            if (value == 'edit') {
              if (!context.mounted) return;
              context.push(
                '/edit-product',
                extra: {
                  'id': widget.productId,
                  'data': data,
                },
              );
              return;
            }

            if (value == 'delete') {
              await _deleteListing(context);
              return;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
            PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
          ],
        ),
      ),
    );
  }
}
