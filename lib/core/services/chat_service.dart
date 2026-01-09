import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  /// ================================
  /// START OR GET CHAT
  /// ================================
  Future<String> startChat({
    required String productId,
    required String sellerId,
  }) async {
    final uid = _uid;

    if (uid == sellerId) {
      throw Exception("You cannot chat with yourself");
    }

    // ✅ Find existing chat for same product and SAME seller (not just any chat with productId)
    final existing = await _db
        .collection('chats')
        .where('productId', isEqualTo: productId)
        .where('participants', arrayContains: uid)
        .get();

    for (final d in existing.docs) {
      final data = d.data();
      final participants = (data['participants'] as List?) ?? [];
      final existingSellerId = (data['sellerId'] ?? '').toString();

      // Ensure this chat is between this buyer and this seller
      if (participants.contains(sellerId) && existingSellerId == sellerId) {
        // ✅ Backfill missing fields for older chats (optional but helpful)
        final updates = <String, dynamic>{};
        if (!data.containsKey('status')) updates['status'] = 'active';
        if (!data.containsKey('rated')) updates['rated'] = false;
        if (!data.containsKey('hiddenFor')) updates['hiddenFor'] = [];
        if (updates.isNotEmpty) {
          await d.reference.update(updates);
        }
        return d.id;
      }
    }

    // ✅ Create new chat with initialized defaults
    final docRef = _db.collection('chats').doc();

    await docRef.set({
      "productId": productId,
      "sellerId": sellerId,
      "buyerId": uid,
      "participants": [uid, sellerId],
      "lastMessage": "",
      "hiddenFor": [],

      // ⭐ rating system defaults
      "status": "active", // active | completed
      "rated": false,

      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// ================================
  /// HIDE CHAT (SOFT DELETE FOR ME)
  /// ================================
  Future<void> hideChatForMe(String chatId) async {
    final uid = _uid;
    await _db.collection('chats').doc(chatId).update({
      'hiddenFor': FieldValue.arrayUnion([uid]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// ================================
  /// SEND MESSAGE
  /// ================================
  Future<void> sendMessage({
    required String chatId,
    required String text,
  }) async {
    final uid = _uid;

    await _db.collection('chats').doc(chatId).collection('messages').add({
      "senderId": uid,
      "text": text,
      "createdAt": FieldValue.serverTimestamp(),
    });

    await _db.collection('chats').doc(chatId).update({
      "lastMessage": text,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }

  /// ================================
  /// MESSAGES STREAM
  /// ================================
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots();
  }

  /// ================================
  /// USER CHAT LIST (STABLE)
  /// ================================
  Stream<QuerySnapshot> getUserChats() {
    return _db
        .collection('chats')
        .where('participants', arrayContains: _uid)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }
}
