import 'package:flutter/material.dart';
import '../layouts/dashboard_layout.dart';
import '../models/commodity_model.dart';
import '../services/commodity_service.dart';
import '../widgets/commodity_form_dialog.dart';
import '../widgets/search_bar.dart';
import '../widgets/pagination_controls.dart';
import '../widgets/data_table_widget.dart';

class CommoditiesScreen extends StatefulWidget {
  const CommoditiesScreen({super.key});

  @override
  State<CommoditiesScreen> createState() => _CommoditiesScreenState();
}

class _CommoditiesScreenState extends State<CommoditiesScreen> {
  final CommodityService _service = CommodityService();
  
  // Table State
  String _searchQuery = '';
  int _sortColumnIndex = 0;
  bool _isAscending = true;
  int _currentPage = 0;
  int _rowsPerPage = 10;

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

  List<CommodityModel> _processData(List<CommodityModel> data) {
    // 1. Filtering
    List<CommodityModel> filtered = data.where((item) {
      return item.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // 2. Sorting
    filtered.sort((a, b) {
      int result = 0;
      if (_sortColumnIndex == 0) { // Name
        result = a.name.compareTo(b.name);
      } else if (_sortColumnIndex == 1) { // Created At
        result = a.createdAt.compareTo(b.createdAt);
      }
      return _isAscending ? result : -result;
    });

    return filtered;
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
              // Header
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
              
              // Search and Filter Row
              AppSearchBar(
                hintText: 'Search by commodity name...',
                onChanged: (value) => setState(() {
                  _searchQuery = value;
                  _currentPage = 0; // Reset pagination on search
                }),
              ),
              const SizedBox(height: 24),

              // Table Content
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
                      final allData = snapshot.data ?? [];
                      final processedData = _processData(allData);
                      
                      // Pagination
                      final int start = _currentPage * _rowsPerPage;
                      final int end = (start + _rowsPerPage) > processedData.length 
                          ? processedData.length 
                          : (start + _rowsPerPage);
                      final List<CommodityModel> pageData = processedData.isEmpty 
                          ? [] 
                          : processedData.sublist(start, end);

                      return Column(
                        children: [
                          Expanded(
                            child: AppDataTable(
                              isLoading: snapshot.connectionState == ConnectionState.waiting,
                              columns: [
                                DataColumn(
                                  label: const Text('Name'),
                                  onSort: (index, ascending) {
                                    setState(() {
                                      _sortColumnIndex = index;
                                      _isAscending = ascending;
                                    });
                                  },
                                ),
                                DataColumn(
                                  label: const Text('Created At'),
                                  onSort: (index, ascending) {
                                    setState(() {
                                      _sortColumnIndex = index;
                                      _isAscending = ascending;
                                    });
                                  },
                                ),
                                const DataColumn(label: Text('Actions')),
                              ],
                              rows: pageData.map((cmd) {
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
                          if (processedData.isNotEmpty)
                            PaginationControls(
                              currentPage: _currentPage,
                              totalItems: processedData.length,
                              rowsPerPage: _rowsPerPage,
                              onPageChanged: (page) => setState(() => _currentPage = page),
                              onRowsPerPageChanged: (value) => setState(() {
                                _rowsPerPage = value!;
                                _currentPage = 0;
                              }),
                            ),
                        ],
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
