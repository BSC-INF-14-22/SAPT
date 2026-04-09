import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a price entry for a commodity in a specific market.
///
/// NOTE: This model uses DENORMALIZATION (storing commodityName and marketName).
/// This is a critical design choice for USSD integration, allowing the backend
/// to fetch and display full price info in a single read without expensive joins.
class PriceModel {
  final String id;
  final String commodityId;
  final String commodityName;
  final String marketId;
  final String marketName;
  final double price;
  final DateTime date;
  final DateTime createdAt;

  PriceModel({
    required this.id,
    required this.commodityId,
    required this.commodityName,
    required this.marketId,
    required this.marketName,
    required this.price,
    required this.date,
    required this.createdAt,
  });

  /// Factory constructor to create a [PriceModel] from a Firestore document.
  factory PriceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PriceModel(
      id: doc.id,
      commodityId: data['commodityId'] ?? '',
      commodityName: data['commodityName'] ?? 'Unknown',
      marketId: data['marketId'] ?? '',
      marketName: data['marketName'] ?? 'Unknown',
      price: (data['price'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts the model into a Map for Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      'commodityId': commodityId,
      'commodityName': commodityName,
      'marketId': marketId,
      'marketName': marketName,
      'price': price,
      'date': Timestamp.fromDate(date),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
