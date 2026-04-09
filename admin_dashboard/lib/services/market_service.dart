import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/market_model.dart';

class MarketService {
  final CollectionReference _db = FirebaseFirestore.instance.collection('markets');

  Stream<List<MarketModel>> getMarketsStream() {
    return _db
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MarketModel.fromDocument(doc))
            .toList());
  }

  Future<void> addMarket(String name, String? location) async {
    final trimmedName = name.trim();
    
    final querySnapshot = await _db
        .where('name', isEqualTo: trimmedName)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      throw Exception('A market with this name already exists.');
    }

    await _db.add({
      'name': trimmedName,
      'location': location?.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateMarket(String id, String newName, String? newLocation) async {
    final trimmedName = newName.trim();

    final querySnapshot = await _db
        .where('name', isEqualTo: trimmedName)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty && querySnapshot.docs.first.id != id) {
      throw Exception('Another market with this name already exists.');
    }

    await _db.doc(id).update({
      'name': trimmedName,
      'location': newLocation?.trim(),
    });
  }

  Future<void> deleteMarket(String id) async {
    await _db.doc(id).delete();
  }
}
