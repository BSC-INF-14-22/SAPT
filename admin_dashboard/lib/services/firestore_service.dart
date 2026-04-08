import 'dart:async';

class FirestoreService {
  /// Simulates fetching total commodities
  Future<int> getTotalCommodities() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return 156;
  }

  /// Simulates fetching total markets
  Future<int> getTotalMarkets() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return 42;
  }

  /// Simulates fetching total price entries
  Future<int> getTotalPriceEntries() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    return 12450;
  }

  /// Simulates fetching the date of the last updated price
  Future<DateTime> getLastUpdatedPriceDate() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return DateTime.now().subtract(const Duration(minutes: 5));
  }
}
