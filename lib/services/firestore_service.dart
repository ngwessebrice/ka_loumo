import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Create product
  Future<void> addProduct(ProductModel product) async {
    await _db.collection("products").doc(product.id).set(product.toMap());
  }

  /// Realtime product list
  Stream<List<ProductModel>> getProducts() {
    return _db.collection("products")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => ProductModel.fromDoc(doc)).toList());
  }

  /// Single product fetch
  Future<ProductModel> getProduct(String id) async {
    final doc = await _db.collection("products").doc(id).get();
    return ProductModel.fromDoc(doc);
  }
}
