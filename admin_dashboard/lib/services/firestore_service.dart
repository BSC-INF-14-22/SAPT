import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Streams for Summary Cards

  /// Real-time total commodities count
  Stream<int> getCommodityCountStream() {
    return _db.collection('commodities').snapshots().map((s) => s.docs.length);
  }

  /// Real-time total markets count
  Stream<int> getMarketCountStream() {
    return _db.collection('markets').snapshots().map((s) => s.docs.length);
  }

  /// Real-time total price entries count
  Stream<int> getPriceEntryCountStream() {
    return _db.collection('prices').snapshots().map((s) => s.docs.length);
  }

  /// Real-time date of the last updated price
  Stream<DateTime?> getLastUpdatedPriceStream() {
    return _db
        .collection('prices')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((s) {
      if (s.docs.isEmpty) return null;
      return (s.docs.first.data()['createdAt'] as Timestamp?)?.toDate();
    });
  }

  // Analytics Streams

  /// Fetches price history for a specific commodity
  Stream<List<Map<String, dynamic>>> getPriceTrends(String commodityId) {
    return _db
        .collection('prices')
        .where('commodityId', isEqualTo: commodityId)
        .snapshots()
        .map((s) {
          final items = s.docs.map((d) {
            final data = d.data();
            data['date'] = (data['date'] as Timestamp?)?.toDate();
            return data;
          }).toList();
          
          // Sort by date ascending in-memory
          items.sort((a, b) {
            final dateA = a['date'] as DateTime?;
            final dateB = b['date'] as DateTime?;
            if (dateA == null || dateB == null) return 0;
            return dateA.compareTo(dateB);
          });
          
          return items.length > 30 ? items.sublist(items.length - 30) : items;
        });
  }

  /// Fetches latest price per market for a commodity
  Stream<List<Map<String, dynamic>>> getMarketComparison(String commodityId) {
    return _db
        .collection('prices')
        .where('commodityId', isEqualTo: commodityId)
        .snapshots()
        .map((s) {
          final Map<String, Map<String, dynamic>> latestByMarket = {};
          
          // First map all to DateTime
          final items = s.docs.map((d) {
            final data = d.data();
            data['date'] = (data['date'] as Timestamp?)?.toDate();
            return data;
          }).toList();

          // Sort by date descending to find latest
          items.sort((a, b) {
            final dateA = a['date'] as DateTime?;
            final dateB = b['date'] as DateTime?;
            if (dateA == null || dateB == null) return 0;
            return dateB.compareTo(dateA);
          });

          for (var data in items) {
            final marketId = data['marketId'];
            if (!latestByMarket.containsKey(marketId)) {
              latestByMarket[marketId] = data;
            }
          }
          return latestByMarket.values.toList();
        });
  }

  /// Combined stream for recent activity from all tracked collections
  /// Simplified: Just track Prices as they are the primary activity.
  Stream<List<Map<String, dynamic>>> getRecentActivityStream() {
    return _db
        .collection('prices')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots()
        .map((s) => s.docs.map((d) {
          final data = d.data();
          return {
            'title': '${data['commodityName']} price updated',
            'subtitle': 'In ${data['marketName']} at MWK ${data['price']}',
            'timestamp': (data['createdAt'] as Timestamp?)?.toDate(),
            'type': 'price',
          };
        }).toList());
  }

  // Legacy Future methods (kept for compatibility)
  Future<int> getTotalCommodities() async {
    final snapshot = await _db.collection('commodities').count().get();
    return snapshot.count ?? 0;
  }

  Future<int> getTotalMarkets() async {
    final snapshot = await _db.collection('markets').count().get();
    return snapshot.count ?? 0;
  }

  Future<int> getTotalPriceEntries() async {
    final snapshot = await _db.collection('prices').count().get();
    return snapshot.count ?? 0;
  }

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
