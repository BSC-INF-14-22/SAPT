import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/price_model.dart';

class PriceService {
  final CollectionReference _db = FirebaseFirestore.instance.collection('prices');

  /// Fetches a real-time stream of all prices ordered by date descending
  Stream<List<PriceModel>> getPricesStream() {
    return _db
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PriceModel.fromDocument(doc))
            .toList());
  }

  /// Adds a new price entry
  Future<void> addPrice({
    required String commodityId,
    required String commodityName,
    required String marketId,
    required String marketName,
    required double price,
    required DateTime date,
  }) async {
    await _db.add({
      'commodityId': commodityId,
      'commodityName': commodityName,
      'marketId': marketId,
      'marketName': marketName,
      'price': price,
      'date': Timestamp.fromDate(date),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Updates an existing price entry
  Future<void> updatePrice({
    required String id,
    required String commodityId,
    required String commodityName,
    required String marketId,
    required String marketName,
    required double price,
    required DateTime date,
  }) async {
    await _db.doc(id).update({
      'commodityId': commodityId,
      'commodityName': commodityName,
      'marketId': marketId,
      'marketName': marketName,
      'price': price,
      'date': Timestamp.fromDate(date),
    });
  }

  /// Deletes a price entry
  Future<void> deletePrice(String id) async {
    await _db.doc(id).delete();
  }
}
