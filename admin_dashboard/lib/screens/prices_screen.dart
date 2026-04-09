import 'package:flutter/material.dart';
import '../layouts/dashboard_layout.dart';
import '../models/price_model.dart';
import '../services/price_service.dart';
import '../widgets/price_form_dialog.dart';

class PricesScreen extends StatefulWidget {
  const PricesScreen({super.key});

  @override
  State<PricesScreen> createState() => _PricesScreenState();
}

class _PricesScreenState extends State<PricesScreen> {
  final PriceService _priceService = PriceService();

  Future<void> _showPriceDialog([PriceModel? price]) async {
    final bool? result = await showDialog(
      context: context,
      builder: (context) => PriceFormDialog(existingPrice: price),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(price == null 
            ? 'Price entry added successfully' 
            : 'Price entry updated successfully'
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );
    }
  }

  Future<void> _confirmDelete(PriceModel price) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Price Entry'),
        content: Text('Are you sure you want to delete this price entry for "${price.commodityName}" at "${price.marketName}"?'),
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
        await _priceService.deletePrice(price.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Price entry deleted'), backgroundColor: Colors.black87),
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
      title: 'Prices',
      currentRoute: '/prices',
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
                      'Price Management',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showPriceDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Price'),
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
                  child: StreamBuilder<List<PriceModel>>(
                    stream: _priceService.getPricesStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.black87));
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error loading prices: ${snapshot.error}'));
                      }

                      final prices = snapshot.data ?? [];

                      if (prices.isEmpty) {
                        return const Center(
                          child: Text(
                            'No price entries found.\nClick "Add Price" to get started.',
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
                              DataColumn(label: Text('Commodity')),
                              DataColumn(label: Text('Market')),
                              DataColumn(label: Text('Price (MWK/kg)')),
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: prices.map((p) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(p.commodityName)),
                                  DataCell(Text(p.marketName)),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'MWK ${p.price.toStringAsFixed(2)} /kg',
                                        style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  DataCell(Text('${p.date.day.toString().padLeft(2, '0')}/${p.date.month.toString().padLeft(2, '0')}/${p.date.year}')),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () => _showPriceDialog(p),
                                          tooltip: 'Edit',
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete, color: Colors.red.shade800),
                                          onPressed: () => _confirmDelete(p),
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
