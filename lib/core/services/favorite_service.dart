import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteService {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final firestore = FirebaseFirestore.instance;

  // Add to favorites
  Future<void> addFavorite(String productId) async {
    await firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(productId)
        .set({
      "productId": productId,
      "timestamp": DateTime.now(),
    });
  }

  // Remove from favorites
  Future<void> removeFavorite(String productId) async {
    await firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(productId)
        .delete();
  }

  // Check if favorited (one-time)
  Future<bool> isFavorite(String productId) async {
    final doc = await firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(productId)
        .get();

    return doc.exists;
  }

  // ✅ NEW: Live favorite state stream (fixes your heart not updating)
  Stream<bool> favoriteStream(String productId) {
    return firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(productId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  // Get all favorite IDs
  Stream<List<String>> getFavoriteIds() {
    return firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toList());
  }
}
