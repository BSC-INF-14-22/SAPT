import 'package:cloud_firestore/cloud_firestore.dart';

class CommodityModel {
  final String id;
  final String name;
  final DateTime createdAt;

  CommodityModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory CommodityModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommodityModel(
      id: doc.id,
      name: data['name'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
