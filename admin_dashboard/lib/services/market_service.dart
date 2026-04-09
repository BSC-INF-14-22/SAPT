import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/market_model.dart';
import 'dart:developer' as developer;

/// Service for managing physical markets.
class MarketService {
  final CollectionReference _db = FirebaseFirestore.instance.collection('markets');

  /// Fetches a real-time stream of all markets.
  /// Optimized with a limit of 100 entries.
  Stream<List<MarketModel>> getMarketsStream() {
    return _db
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MarketModel.fromFirestore(doc))
            .toList());
  }

  /// Adds a new market. Checks for duplicates by name.
  Future<void> addMarket(String name, String? location) async {
    try {
      final trimmedName = name.trim();
      
      final querySnapshot = await _db
          .where('name', isEqualTo: trimmedName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        throw 'A market with the name "$trimmedName" already exists.';
      }

      await _db.add({
        'name': trimmedName,
        'location': location?.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      developer.log('Error adding market: $e');
      rethrow;
    }
  }

  /// Updates an existing market's details.
  Future<void> updateMarket(String id, String newName, String? newLocation) async {
    try {
      final trimmedName = newName.trim();

      final querySnapshot = await _db
          .where('name', isEqualTo: trimmedName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty && querySnapshot.docs.first.id != id) {
        throw 'Another market with the name "$trimmedName" already exists.';
      }

      await _db.doc(id).update({
        'name': trimmedName,
        'location': newLocation?.trim(),
      });
    } catch (e) {
      developer.log('Error updating market: $e');
      rethrow;
    }
  }

  /// Deletes a market permanently.
  Future<void> deleteMarket(String id) async {
    try {
      await _db.doc(id).delete();
    } catch (e) {
      developer.log('Error deleting market: $e');
      rethrow;
    }
  }
}
