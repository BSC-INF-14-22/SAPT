import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/commodity_model.dart';
import 'dart:developer' as developer;

/// Service for managing agricultural commodities.
///
/// USSD INTEGRATION:
/// Commodities are primary keys for USSD price lookups. 
/// Efficient indexing on the 'name' field ensures that USSD keyword searches
/// remain responsive under high load.
class CommodityService {
  final CollectionReference _db = FirebaseFirestore.instance.collection('commodities');

  /// Fetches a real-time stream of all commodities.
  /// Optimized with a limit of 100 to prevent large reads in early scaling.
  Stream<List<CommodityModel>> getCommoditiesStream() {
    return _db
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommodityModel.fromFirestore(doc))
            .toList());
  }

  /// Adds a new commodity. Checks for duplicates first.
  Future<void> addCommodity(String name) async {
    try {
      final trimmedName = name.trim();
      
      final querySnapshot = await _db
          .where('name', isEqualTo: trimmedName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        throw 'A commodity with the name "$trimmedName" already exists.';
      }

      await _db.add({
        'name': trimmedName,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      developer.log('Error adding commodity: $e');
      rethrow;
    }
  }

  /// Updates an existing commodity's name.
  Future<void> updateCommodity(String id, String newName) async {
    try {
      final trimmedName = newName.trim();

      final querySnapshot = await _db
          .where('name', isEqualTo: trimmedName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty && querySnapshot.docs.first.id != id) {
        throw 'Another commodity with the name "$trimmedName" already exists.';
      }

      await _db.doc(id).update({
        'name': trimmedName,
      });
    } catch (e) {
      developer.log('Error updating commodity: $e');
      rethrow;
    }
  }

  /// Deletes a commodity.
  Future<void> deleteCommodity(String id) async {
    try {
      await _db.doc(id).delete();
    } catch (e) {
      developer.log('Error deleting commodity: $e');
      rethrow;
    }
  }
}
