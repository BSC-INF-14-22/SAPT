import 'package:cloud_firestore/cloud_firestore.dart';

class MarketModel {
  final String id;
  final String name;
  final String? location;
  final DateTime createdAt;

  MarketModel({
    required this.id,
    required this.name,
    this.location,
    required this.createdAt,
  });

  factory MarketModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MarketModel(
      id: doc.id,
      name: data['name'] ?? '',
      location: data['location'] == '' ? null : data['location'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
