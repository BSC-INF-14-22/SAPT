import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../widgets/summary_card.dart';
import '../layouts/dashboard_layout.dart';
import '../widgets/charts/price_trend_chart.dart';
import '../widgets/charts/market_comparison_chart.dart';
import '../widgets/recent_activity.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return DashboardLayout(
      title: 'Overview',
      currentRoute: '/dashboard',
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
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
              const SizedBox(height: 16),
              
              // Summary Cards Section
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 1;
                  double childAspectRatio = 1.3; // Default for mobile height

                  if (constraints.maxWidth >= 1200) {
                    crossAxisCount = 4;
                    childAspectRatio = 1.5;
                  } else if (constraints.maxWidth >= 800) {
                    crossAxisCount = 2;
                    childAspectRatio = 1.6;
                  } else if (constraints.maxWidth >= 600) {
                    crossAxisCount = 2;
                    childAspectRatio = 1.4;
                  }

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: isMobile ? 16 : 24,
                    mainAxisSpacing: isMobile ? 16 : 24,
                    childAspectRatio: childAspectRatio,
                    children: [
                      StreamBuilder<int>(
                        stream: _firestoreService.getCommodityCountStream(),
                        builder: (context, snapshot) => SummaryCard(
                          title: 'Total Commodities',
                          value: '${snapshot.data ?? 0}',
                          icon: Icons.eco,
                          iconBackgroundColor: const Color(0xFF2E7D32),
                          isLoading: snapshot.connectionState == ConnectionState.waiting,
                        ),
                      ),
                      StreamBuilder<int>(
                        stream: _firestoreService.getMarketCountStream(),
                        builder: (context, snapshot) => SummaryCard(
                          title: 'Active Markets',
                          value: '${snapshot.data ?? 0}',
                          icon: Icons.storefront,
                          iconBackgroundColor: const Color(0xFFE53935),
                          isLoading: snapshot.connectionState == ConnectionState.waiting,
                        ),
                      ),
                      StreamBuilder<int>(
                        stream: _firestoreService.getPriceEntryCountStream(),
                        builder: (context, snapshot) => SummaryCard(
                          title: 'Total Price Entries',
                          value: '${snapshot.data ?? 0}',
                          icon: Icons.analytics,
                          iconBackgroundColor: const Color(0xFFFFEB3B),
                          isLoading: snapshot.connectionState == ConnectionState.waiting,
                        ),
                      ),
                      StreamBuilder<DateTime?>(
                        stream: _firestoreService.getLastUpdatedPriceStream(),
                        builder: (context, snapshot) {
                          final lastUpdated = snapshot.data;
                          return SummaryCard(
                            title: 'Last Updated',
                            value: lastUpdated != null 
                                ? '${lastUpdated.hour.toString().padLeft(2, '0')}:${lastUpdated.minute.toString().padLeft(2, '0')}' 
                                : '-',
                            subtitle: lastUpdated != null
                                ? '${lastUpdated.day}/${lastUpdated.month}/${lastUpdated.year}'
                                : null,
                            icon: Icons.access_time,
                            iconBackgroundColor: const Color(0xFF000000),
                            isLoading: snapshot.connectionState == ConnectionState.waiting,
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // Charts Section
              const Text(
                'Data Insights',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 1024) {
                    return const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: PriceTrendChart()),
                        SizedBox(width: 24),
                        Expanded(child: MarketComparisonChart()),
                      ],
                    );
                  } else {
                    return const Column(
                      children: [
                        PriceTrendChart(),
                        SizedBox(height: 24),
                        MarketComparisonChart(),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 32),

              // Recent Activity Section
              const RecentActivity(),
            ],
          ),
        ),
      ),
    );
  }
}
