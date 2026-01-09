import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/product_model.dart';

class ProductService {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  /// ✅ Upload product images to:
  /// products/<ownerId>/<productId>/image_<i>.jpg
  Future<List<String>> uploadImages({
    required String ownerId,
    required String productId,
    required List<File> imgs,
  }) async {
    final List<String> urls = [];

    for (int i = 0; i < imgs.length; i++) {
      final ref = _storage.ref().child("products/$ownerId/$productId/image_$i.jpg");

      final uploadTask = ref.putFile(
        imgs[i],
        SettableMetadata(contentType: "image/jpeg"),
      );

      final snap = await uploadTask;
      final url = await snap.ref.getDownloadURL();
      urls.add(url);
    }

    return urls;
  }

  /// ✅ MARK PRODUCT AS SOLD
  Future<void> markAsSold(String productId) async {
    await _db.collection("products").doc(productId).set({
      "isSold": true,
      "status": "sold",
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// ✅ Create product
  Future<String> createProduct({
    required String title,
    required String description,
    required String category,
    required int price,
    required String ownerId,
    required List<File> images,
    String location = "conakry",
    String condition = "new",

    String status = "active",
    bool isBoosted = false,
    DateTime? boostUntil,
  }) async {
    final String productId = const Uuid().v4();

    // ✅ upload images with correct secure path
    final List<String> imgUrls = await uploadImages(
      ownerId: ownerId,
      productId: productId,
      imgs: images,
    );

    final item = ProductModel(
      id: productId,
      title: title,
      description: description,
      price: price,
      category: category,
      images: imgUrls,
      ownerId: ownerId,
      location: location,
      condition: condition,
      createdBy: ownerId,
      createdAt: DateTime.now(),
      isSold: false,
    );

    // 1) base doc
    await _db.collection("products").doc(productId).set(item.toMap());

    // 2) merge business fields
    await _db.collection("products").doc(productId).set({
      "status": status,
      "isBoosted": isBoosted,
      "boostUntil": boostUntil == null ? null : Timestamp.fromDate(boostUntil),
      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
      "ownerId": ownerId,
    }, SetOptions(merge: true));

    return productId;
  }

  /// ✅ Home feed
  Stream<List<ProductModel>> getProducts() {
    return _db
        .collection("products")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ProductModel.fromDoc(d)).toList());
  }

  /// ✅ User products
  Stream<List<ProductModel>> getUserProducts(String uid) {
    return _db
        .collection("products")
        .where("ownerId", isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ProductModel.fromDoc(d)).toList());
  }

  /// ✅ Single product
  Stream<ProductModel> getProductById(String id) {
    return _db.collection("products").doc(id).snapshots().map(
          (doc) => ProductModel.fromDoc(doc),
    );
  }
}
