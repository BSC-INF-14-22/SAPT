import 'package:flutter/material.dart';
import '../layouts/dashboard_layout.dart';
import '../models/commodity_model.dart';
import '../services/commodity_service.dart';
import '../widgets/commodity_form_dialog.dart';

class CommoditiesScreen extends StatefulWidget {
  const CommoditiesScreen({super.key});

  @override
  State<CommoditiesScreen> createState() => _CommoditiesScreenState();
}

class _CommoditiesScreenState extends State<CommoditiesScreen> {
  final CommodityService _service = CommodityService();

  Future<void> _showCommodityDialog([CommodityModel? commodity]) async {
    final bool? result = await showDialog(
      context: context,
      builder: (context) => CommodityFormDialog(existingCommodity: commodity),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(commodity == null 
            ? 'Commodity added successfully' 
            : 'Commodity updated successfully'
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );
    }
  }

  Future<void> _confirmDelete(CommodityModel commodity) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Commodity'),
        content: Text('Are you sure you want to delete "${commodity.name}"?\nThis action cannot be undone.'),
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
        await _service.deleteCommodity(commodity.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Commodity deleted'), backgroundColor: Colors.black87),
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
      title: 'Commodities',
      currentRoute: '/commodities',
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
                      'Commodity Management',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showCommodityDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Commodity'),
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
                  child: StreamBuilder<List<CommodityModel>>(
                    stream: _service.getCommoditiesStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.black87));
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error loading commodities: ${snapshot.error}'));
                      }

                      final commodities = snapshot.data ?? [];

                      if (commodities.isEmpty) {
                        return const Center(
                          child: Text(
                            'No commodities found.\nClick "Add Commodity" to get started.',
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
                              DataColumn(label: Text('Created At')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: commodities.map((cmd) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(cmd.name)),
                                  DataCell(Text('${cmd.createdAt.day.toString().padLeft(2, '0')}/${cmd.createdAt.month.toString().padLeft(2, '0')}/${cmd.createdAt.year}')),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          onPressed: () => _showCommodityDialog(cmd),
                                          tooltip: 'Edit',
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete, color: Colors.red.shade800),
                                          onPressed: () => _confirmDelete(cmd),
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
