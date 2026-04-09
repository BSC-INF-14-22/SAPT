import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/firestore_service.dart';
import '../../services/commodity_service.dart';
import '../../models/commodity_model.dart';

class MarketComparisonChart extends StatefulWidget {
  const MarketComparisonChart({super.key});

  @override
  State<MarketComparisonChart> createState() => _MarketComparisonChartState();
}

class _MarketComparisonChartState extends State<MarketComparisonChart> {
  final FirestoreService _firestoreService = FirestoreService();
  final CommodityService _commodityService = CommodityService();
  String? _selectedCommodityId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Market Comparison',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              StreamBuilder<List<CommodityModel>>(
                stream: _commodityService.getCommoditiesStream(),
                builder: (context, snapshot) {
                  final commodities = snapshot.data ?? [];
                  if (commodities.isNotEmpty && _selectedCommodityId == null) {
                    _selectedCommodityId = commodities.first.id;
                  }

                  return DropdownButton<String>(
                    value: _selectedCommodityId,
                    underline: const SizedBox(),
                    items: commodities.map((c) {
                      return DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedCommodityId = val),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: _selectedCommodityId == null
                ? const Center(child: Text('Select a commodity'))
                : StreamBuilder<List<Map<String, dynamic>>>(
                    stream: _firestoreService.getMarketComparison(_selectedCommodityId!),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final data = snapshot.data ?? [];
                      if (data.isEmpty) {
                        return const Center(child: Text('No comparative data available'));
                      }

                      return BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: data.map((e) => e['price'] as num).reduce((a, b) => a > b ? a : b).toDouble() * 1.2,
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(fontSize: 10, color: Colors.black45),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final int index = value.toInt();
                                  if (index >= 0 && index < data.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        data[index]['marketName'],
                                        style: const TextStyle(fontSize: 10, color: Colors.black45),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: data.asMap().entries.map((e) {
                            return BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(
                                  toY: (e.value['price'] as num).toDouble(),
                                  color: Colors.black87,
                                  width: 16,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
