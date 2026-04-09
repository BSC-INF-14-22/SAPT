import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a physical market location (e.g., Lilongwe Market).
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

  /// Factory constructor to create a [MarketModel] from a Firestore document.
  factory MarketModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return MarketModel(
      id: doc.id,
      name: data['name'] ?? 'Unknown Market',
      location: (data['location'] == '' || data['location'] == null) ? null : data['location'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts the model into a Map for Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      'name': name.trim(),
      'location': location?.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
