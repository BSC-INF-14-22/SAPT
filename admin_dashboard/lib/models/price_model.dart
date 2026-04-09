import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory PriceModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PriceModel(
      id: doc.id,
      commodityId: data['commodityId'] ?? '',
      commodityName: data['commodityName'] ?? '',
      marketId: data['marketId'] ?? '',
      marketName: data['marketName'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'commodityId': commodityId,
      'commodityName': commodityName,
      'marketId': marketId,
      'marketName': marketName,
      'price': price,
      'date': Timestamp.fromDate(date),
      'createdAt': createdAt == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(createdAt),
    };
  }
}
