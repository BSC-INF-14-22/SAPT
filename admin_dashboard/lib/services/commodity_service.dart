import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/commodity_model.dart';

class CommodityService {
  final CollectionReference _db = FirebaseFirestore.instance.collection('commodities');

  /// Fetches a real-time stream of all commodities ordered by creation date
  Stream<List<CommodityModel>> getCommoditiesStream() {
    return _db
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommodityModel.fromDocument(doc))
            .toList());
  }

  /// Adds a new commodity if the exact name does not already exist
  Future<void> addCommodity(String name) async {
    final trimmedName = name.trim();
    
    // Attempt duplicate prevention
    final querySnapshot = await _db
        .where('name', isEqualTo: trimmedName)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      throw Exception('A commodity with this name already exists.');
    }

    await _db.add({
      'name': trimmedName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Updates the name of an existing commodity
  Future<void> updateCommodity(String id, String newName) async {
    final trimmedName = newName.trim();

    // Optionally check if the new name is a duplicate among OTHER documents
    final querySnapshot = await _db
        .where('name', isEqualTo: trimmedName)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty && querySnapshot.docs.first.id != id) {
      throw Exception('Another commodity with this name already exists.');
    }

    await _db.doc(id).update({
      'name': trimmedName,
    });
  }

  /// Deletes a commodity permanently
  Future<void> deleteCommodity(String id) async {
    await _db.doc(id).delete();
  }
}
