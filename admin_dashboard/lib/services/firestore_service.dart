import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Fetches real total commodities count
  Future<int> getTotalCommodities() async {
    final snapshot = await _db.collection('commodities').count().get();
    return snapshot.count ?? 0;
  }

  /// Fetches real total markets count
  Future<int> getTotalMarkets() async {
    final snapshot = await _db.collection('markets').count().get();
    return snapshot.count ?? 0;
  }

  /// Fetches real total price entries count
  Future<int> getTotalPriceEntries() async {
    final snapshot = await _db.collection('prices').count().get();
    return snapshot.count ?? 0;
  }

  /// Fetches the date of the last updated price
  Future<DateTime?> getLastUpdatedPriceDate() async {
    final snapshot = await _db
        .collection('prices')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    
    final data = snapshot.docs.first.data();
    return (data['createdAt'] as Timestamp?)?.toDate();
  }
}
