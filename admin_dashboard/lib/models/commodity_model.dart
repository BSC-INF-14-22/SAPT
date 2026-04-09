import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing an agricultural commodity (e.g., Maize, Rice).
class CommodityModel {
  final String id;
  final String name;
  final DateTime createdAt;

  CommodityModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  /// Factory constructor to create a [CommodityModel] from a Firestore document.
  factory CommodityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CommodityModel(
      id: doc.id,
      name: data['name'] ?? 'Unknown',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts the model into a Map for Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      'name': name.trim(),
      'createdAt': FieldValue.serverTimestamp(), // Always use server timestamp on creation
    };
  }
}
