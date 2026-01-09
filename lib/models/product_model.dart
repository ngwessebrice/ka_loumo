import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String title;
  final String description;
  final int price;
  final String category;
  final List<String> images;
  final String ownerId;
  final String location;
  final String condition;
  final String createdBy;
  final DateTime createdAt;

  final bool isSold; // ✅ NEW

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.images,
    required this.ownerId,
    required this.location,
    required this.condition,
    required this.createdBy,
    required this.createdAt,
    required this.isSold,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "price": price,
      "category": category,
      "images": images,
      "ownerId": ownerId,
      "location": location,
      "condition": condition,
      "createdBy": createdBy,
      "createdAt": createdAt,
      "isSold": isSold, // ✅
    };
  }

  factory ProductModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ProductModel(
      id: data['id'] ?? "",
      title: data['title'] ?? "",
      description: data['description'] ?? "",
      price: data['price'] ?? 0,
      category: data['category'] ?? "",
      images: List<String>.from(data['images'] ?? []),
      ownerId: data['ownerId'] ?? "",
      location: data['location'] ?? "",
      condition: data['condition'] ?? "",
      createdBy: data['createdBy'] ?? "",
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isSold: data['isSold'] ?? false, // ✅ SAFE DEFAULT
    );
  }
}
