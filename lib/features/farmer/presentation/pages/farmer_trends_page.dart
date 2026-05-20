import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FarmerTrendsPage extends StatefulWidget {
  const FarmerTrendsPage({super.key});

  @override
  State<FarmerTrendsPage> createState() => _FarmerTrendsPageState();
}

class _FarmerTrendsPageState extends State<FarmerTrendsPage> {
  String? _selectedCrop;
  String _timeframe = 'Weekly'; // Weekly or Monthly
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Price Trends')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSelectors(theme),
            const SizedBox(height: 32),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('price_history')
                  .where('cropName', isEqualTo: _selectedCrop)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final allDocs = snapshot.data?.docs ?? [];
                
                DateTime now = DateTime.now();
                DateTime startDate;
                switch (_timeframe) {
                  case 'Daily':
                    startDate = now.subtract(const Duration(days: 7)); // Last 7 days
                    break;
                  case 'Monthly':
                    startDate = DateTime(now.year, now.month - 6, now.day); // Last 6 months
                    break;
                  case 'Weekly':
                  default:
                    startDate = now.subtract(const Duration(days: 30)); // Last 4 weeks
                    break;
                }

                final filteredDocs = allDocs.where((doc) {
                  if (doc.data().containsKey('date') && doc['date'] != null) {
                    final date = (doc['date'] as Timestamp).toDate();
                    return date.isAfter(startDate);
                  }
                  return false;
                }).toList();

                // Sort in-memory to avoid composite index requirement
                final docs = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(filteredDocs);
                docs.sort((a, b) {
                  final aTime = a.data()['date'] as Timestamp?;
                  final bTime = b.data()['date'] as Timestamp?;
                  if (aTime == null) return 1;
                  if (bTime == null) return -1;
                  return aTime.compareTo(bTime); // Ascending
                });

                if (docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text('No historical data available for this crop.'),
                    ),
                  );
                }

                // Calculate Stats
                final prices = docs.map((e) => double.tryParse(e.data()['price'].toString()) ?? 0.0).toList();
                final highest = prices.reduce((a, b) => a > b ? a : b);
                final lowest = prices.reduce((a, b) => a < b ? a : b);
                final projection = _generateProjection(docs);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildChart(theme, docs),
                    const SizedBox(height: 32),
                    _buildStatsSection(theme, highest, lowest, projection),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectors(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Crop Selector (Dynamic from Firestore)
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LinearProgressIndicator();
            }

            final productNames = snapshot.data?.docs
                .map((d) => d.data()['name'] as String)
                .toList() ?? [];
            
            productNames.sort();

            if (_selectedCrop == null && productNames.isNotEmpty) {
              _selectedCrop = productNames.first;
            } else if (_selectedCrop != null && !productNames.contains(_selectedCrop)) {
              _selectedCrop = productNames.first;
            }

            return DropdownButtonFormField<String>(
              value: _selectedCrop,
              decoration: const InputDecoration(
                labelText: 'Crop Filter',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: productNames.map((crop) => DropdownMenuItem(value: crop, child: Text(crop))).toList(),
              onChanged: (val) => setState(() => _selectedCrop = val),
            );
          },
        ),
        const SizedBox(height: 16),
        // Timeframe Toggle
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: theme.primaryColor.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeframeButton('Daily'),
                _buildTimeframeButton('Weekly'),
                _buildTimeframeButton('Monthly'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeframeButton(String label) {
    final isSelected = _timeframe == label;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => setState(() => _timeframe = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _generateProjection(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    if (docs.length < 3) return 'Collecting more data for accurate projections...';

    final prices = docs.map((d) => double.tryParse(d.data()['price'].toString()) ?? 0.0).toList();
    final dates = docs.map((d) => (d.data()['date'] as Timestamp).toDate()).toList();

    // Simple Linear Regression: y = mx + c
    int n = prices.length;
    double sumX = 0; // days from start
    double sumY = 0; // prices
    double sumXY = 0;
    double sumX2 = 0;

    DateTime startDate = dates.first;
    for (int i = 0; i < n; i++) {
      double x = dates[i].difference(startDate).inDays.toDouble();
      double y = prices[i];
      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }

    double denominator = (n * sumX2 - sumX * sumX);
    if (denominator == 0) return 'Prices for $_selectedCrop are holding steady.';

    double slope = (n * sumXY - sumX * sumY) / denominator;

    // Predict for next week (7 days after the last data point)
    double lastX = dates.last.difference(startDate).inDays.toDouble();
    double predictionX = lastX + 7;
    double intercept = (sumY - slope * sumX) / n;
    double predictedPrice = slope * predictionX + intercept;

    double lastPrice = prices.last;
    double percentageChange = ((predictedPrice - lastPrice) / lastPrice) * 100;

    String trend = slope > 0 ? 'rise' : 'fall';
    if (slope.abs() < 0.1) return 'Prices for $_selectedCrop are expected to remain stable next week.';

    return 'Prices for $_selectedCrop are projected to $trend by ${percentageChange.abs().toStringAsFixed(1)}% next week based on market velocity.';
  }

  Widget _buildChart(ThemeData theme, List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    return Container(
      height: 300,
      padding: const EdgeInsets.only(right: 16, top: 16, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < docs.length) {
                    final date = (docs[value.toInt()]['date'] as Timestamp).toDate();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('dd/MM').format(date),
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    );
                  }
                  return const Text('');
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                reservedSize: 40,
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: docs.asMap().entries.map((e) {
                final price = double.tryParse(e.value.data()['price'].toString()) ?? 0;
                return FlSpot(e.key.toDouble(), price);
              }).toList(),
              isCurved: true,
              color: theme.primaryColor,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: theme.primaryColor.withAlpha(25),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme, double highest, double lowest, String projection) {
    final currencyFormat = NumberFormat.currency(symbol: 'MK ', decimalDigits: 0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Stats',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatCard(
              'Highest',
              currencyFormat.format(highest),
              Icons.arrow_upward,
              Colors.green,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              'Lowest',
              currencyFormat.format(lowest),
              Icons.arrow_downward,
              Colors.red,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildTrendAlert(theme, projection),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(13),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendAlert(ThemeData theme, String projection) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withAlpha(50)),
      ),
      child: Row(
        children: [
          const Icon(Icons.analytics_outlined, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Market Projection',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 4),
                Text(
                  projection,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
