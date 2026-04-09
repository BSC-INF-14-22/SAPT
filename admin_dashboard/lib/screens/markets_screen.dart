import 'package:flutter/material.dart';
import '../layouts/dashboard_layout.dart';
import '../models/market_model.dart';
import '../services/market_service.dart';
import '../widgets/market_form_dialog.dart';

class MarketsScreen extends StatefulWidget {
  const MarketsScreen({super.key});

  @override
  State<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends State<MarketsScreen> {
  final MarketService _service = MarketService();

  Future<void> _showMarketDialog([MarketModel? market]) async {
    final bool? result = await showDialog(
      context: context,
      builder: (context) => MarketFormDialog(existingMarket: market),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(market == null 
            ? 'Market added successfully' 
            : 'Market updated successfully'
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );
    }
  }

  Future<void> _confirmDelete(MarketModel market) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Market'),
        content: Text('Are you sure you want to delete "${market.name}"?\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _service.deleteMarket(market.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Market deleted'), backgroundColor: Colors.black87),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.red.shade800),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'Markets',
      currentRoute: '/markets',
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    const Text(
                      'Market Management',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showMarketDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Market'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: StreamBuilder<List<MarketModel>>(
                    stream: _service.getMarketsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.black87));
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error loading markets: ${snapshot.error}'));
                      }

                      final markets = snapshot.data ?? [];

                      if (markets.isEmpty) {
                        return const Center(
                          child: Text(
                            'No markets found.\nClick "Add Market" to get started.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.black54, fontSize: 16),
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                            columns: const [
                              DataColumn(label: Text('Name')),
                              DataColumn(label: Text('Location')),
                              DataColumn(label: Text('Created At')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: markets.map((mkt) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(mkt.name)),
                                  DataCell(Text(mkt.location ?? '-')),
                                  DataCell(Text('${mkt.createdAt.day.toString().padLeft(2, '0')}/${mkt.createdAt.month.toString().padLeft(2, '0')}/${mkt.createdAt.year}')),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () => _showMarketDialog(mkt),
                                          tooltip: 'Edit',
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete, color: Colors.red.shade800),
                                          onPressed: () => _confirmDelete(mkt),
                                          tooltip: 'Delete',
                                        ),
                                      ],
                                    ),
                                  ),
                                ]
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
