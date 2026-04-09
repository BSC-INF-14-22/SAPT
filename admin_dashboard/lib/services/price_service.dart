import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/price_model.dart';
import 'dart:developer' as developer;

/// Service for managing commodity price entries.
///
/// OPTIMIZATION FOR USSD:
/// This service handles price data which is the primary consumer of USSD requests.
/// To support the low-latency requirements of USSD, we use a DENORMALIZED schema
/// where commodity and market names are stored within the price document.
/// This allows the USSD backend to fetch a complete "Market Price Report" in
/// a single Firestore read, avoiding the performance penalty of multi-collection joins.
class PriceService {
  final CollectionReference _db = FirebaseFirestore.instance.collection('prices');

  /// Fetches a real-time stream of all prices.
  ///
  /// QUERY DESIGN:
  /// - .orderBy('date', descending: true): Ensures the most recent market data is shown first.
  /// - .limit(150): Prevents massive data transfers as the database scales, maintaining
  ///   dashboard performance and UI responsiveness.
  Stream<List<PriceModel>> getPricesStream() {
    return _db
        .orderBy('date', descending: true)
        .limit(150)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PriceModel.fromFirestore(doc))
            .toList());
  }

  /// Adds a new price entry.
  /// Ensures denormalized names are correctly stored.
  Future<void> addPrice({
    required String commodityId,
    required String commodityName,
    required String marketId,
    required String marketName,
    required double price,
    required DateTime date,
  }) async {
    try {
      await _db.add({
        'commodityId': commodityId,
        'commodityName': commodityName,
        'marketId': marketId,
        'marketName': marketName,
        'price': price,
        'date': Timestamp.fromDate(date),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      developer.log('Error adding price: $e');
      rethrow;
    }
  }

  /// Updates an existing price entry.
  Future<void> updatePrice({
    required String id,
    required String commodityId,
    required String commodityName,
    required String marketId,
    required String marketName,
    required double price,
    required DateTime date,
  }) async {
    try {
      await _db.doc(id).update({
        'commodityId': commodityId,
        'commodityName': commodityName,
        'marketId': marketId,
        'marketName': marketName,
        'price': price,
        'date': Timestamp.fromDate(date),
      });
    } catch (e) {
      developer.log('Error updating price: $e');
      rethrow;
    }
  }

  /// Deletes a price entry.
  Future<void> deletePrice(String id) async {
    try {
      await _db.doc(id).delete();
    } catch (e) {
      developer.log('Error deleting price: $e');
      rethrow;
    }
  }
}
