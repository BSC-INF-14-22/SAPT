import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../widgets/summary_card.dart';
import '../layouts/dashboard_layout.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  final FirestoreService _firestoreService = FirestoreService();
  
  bool _isLoading = true;
  int _totalCommodities = 0;
  int _totalMarkets = 0;
  int _totalPriceEntries = 0;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _firestoreService.getTotalCommodities(),
        _firestoreService.getTotalMarkets(),
        _firestoreService.getTotalPriceEntries(),
      ]);
      
      final lastUpdateDate = await _firestoreService.getLastUpdatedPriceDate();

      if (mounted) {
        setState(() {
          _totalCommodities = results[0];
          _totalMarkets = results[1];
          _totalPriceEntries = results[2];
          _lastUpdated = lastUpdateDate;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'Overview',
      currentRoute: '/dashboard',
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Market Intelligence Summary',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Determine grid columns based on screen width
                    int crossAxisCount = 1;
                    if (constraints.maxWidth >= 1200) {
                      crossAxisCount = 4;
                    } else if (constraints.maxWidth >= 800) {
                      crossAxisCount = 2;
                    }

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: constraints.maxWidth >= 800 ? 1.5 : 2.5,
                      children: [
                        SummaryCard(
                          title: 'Total Commodities',
                          value: '$_totalCommodities',
                          icon: Icons.eco,
                          iconBackgroundColor: const Color(0xFF2E7D32), // Green
                          isLoading: _isLoading,
                        ),
                        SummaryCard(
                          title: 'Active Markets',
                          value: '$_totalMarkets',
                          icon: Icons.storefront,
                          iconBackgroundColor: const Color(0xFFE53935), // Red
                          isLoading: _isLoading,
                        ),
                        SummaryCard(
                          title: 'Total Price Entries',
                          value: '$_totalPriceEntries',
                          icon: Icons.analytics,
                          iconBackgroundColor: const Color(0xFFFFEB3B), // Yellow
                          isLoading: _isLoading,
                        ),
                        SummaryCard(
                          title: 'Last Updated',
                          value: _lastUpdated != null 
                              ? '${_lastUpdated!.hour.toString().padLeft(2, '0')}:${_lastUpdated!.minute.toString().padLeft(2, '0')}' 
                              : '-',
                          subtitle: _lastUpdated != null
                              ? '${_lastUpdated!.day}/${_lastUpdated!.month}/${_lastUpdated!.year}'
                              : null,
                          icon: Icons.access_time,
                          iconBackgroundColor: const Color(0xFF000000), // Black
                          isLoading: _isLoading,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
