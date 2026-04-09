import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/price_model.dart';

/// Service responsible for aggregate dashboard data and analytics.
///
/// USSD READINESS:
/// Optimized counting methods and real-time streams provide the telemetry
/// needed to monitor system health and USSD session density.
class DashboardService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Real-time Streams for Counters ---

  /// Stream of total commodity count.
  Stream<int> getCommodityCountStream() {
    return _db.collection('commodities').snapshots().map((s) => s.docs.length);
  }

  /// Stream of total market count.
  Stream<int> getMarketCountStream() {
    return _db.collection('markets').snapshots().map((s) => s.docs.length);
  }

  /// Stream of total price entry count.
  Stream<int> getPriceEntryCountStream() {
    return _db.collection('prices').snapshots().map((s) => s.docs.length);
  }

  /// Stream of the most recent price update timestamp.
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

  // --- Analytics Streams ---

  /// Stream of price history for a specific commodity for trend charts.
  /// Includes in-memory sorting to avoid mandatory composite indexes during development.
  Stream<List<PriceModel>> getPriceTrends(String commodityId) {
    return _db
        .collection('prices')
        .where('commodityId', isEqualTo: commodityId)
        .snapshots()
        .map((s) {
      final items = s.docs.map((d) => PriceModel.fromFirestore(d)).toList();

      // Sort by date ascending in-memory
      items.sort((a, b) => a.date.compareTo(b.date));

      // Limit to last 30 for performance
      return items.length > 30 ? items.sublist(items.length - 30) : items;
    });
  }

  /// Stream of latest prices per market for a commodity (comparison chart).
  Stream<List<PriceModel>> getMarketComparison(String commodityId) {
    return _db
        .collection('prices')
        .where('commodityId', isEqualTo: commodityId)
        .snapshots()
        .map((s) {
      final Map<String, PriceModel> latestByMarket = {};

      final items = s.docs.map((d) => PriceModel.fromFirestore(d)).toList();

      // Sort by date descending to find latest
      items.sort((a, b) => b.date.compareTo(a.date));

      for (var model in items) {
        if (!latestByMarket.containsKey(model.marketId)) {
          latestByMarket[model.marketId] = model;
        }
      }
      return latestByMarket.values.toList();
    });
  }

  /// Stream for the recent activity log.
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
              };
            }).toList());
  }
}
