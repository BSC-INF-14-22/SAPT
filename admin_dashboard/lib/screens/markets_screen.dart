import 'package:flutter/material.dart';
import '../layouts/dashboard_layout.dart';
import '../models/market_model.dart';
import '../services/market_service.dart';
import '../widgets/market_form_dialog.dart';
import '../widgets/search_bar.dart';
import '../widgets/pagination_controls.dart';
import '../widgets/data_table_widget.dart';

class MarketsScreen extends StatefulWidget {
  const MarketsScreen({super.key});

  @override
  State<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends State<MarketsScreen> {
  final MarketService _service = MarketService();

  // Table State
  String _searchQuery = '';
  int _sortColumnIndex = 0;
  bool _isAscending = true;
  int _currentPage = 0;
  int _rowsPerPage = 10;

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

  List<MarketModel> _processData(List<MarketModel> data) {
    // 1. Filtering
    List<MarketModel> filtered = data.where((item) {
      final nameMatches = item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final locationMatches = (item.location ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
      return nameMatches || locationMatches;
    }).toList();

    // 2. Sorting
    filtered.sort((a, b) {
      int result = 0;
      if (_sortColumnIndex == 0) { // Name
        result = a.name.compareTo(b.name);
      } else if (_sortColumnIndex == 1) { // Location
        result = (a.location ?? '').compareTo(b.location ?? '');
      } else if (_sortColumnIndex == 2) { // Created At
        result = a.createdAt.compareTo(b.createdAt);
      }
      return _isAscending ? result : -result;
    });

    return filtered;
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

              // Search Row
              AppSearchBar(
                hintText: 'Search by market name or location...',
                onChanged: (value) => setState(() {
                  _searchQuery = value;
                  _currentPage = 0;
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
                  child: StreamBuilder<List<MarketModel>>(
                    stream: _service.getMarketsStream(),
                    builder: (context, snapshot) {
                      final allData = snapshot.data ?? [];
                      final processedData = _processData(allData);

                      // Pagination
                      final int start = _currentPage * _rowsPerPage;
                      final int end = (start + _rowsPerPage) > processedData.length 
                          ? processedData.length 
                          : (start + _rowsPerPage);
                      final List<MarketModel> pageData = processedData.isEmpty 
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
                                  label: const Text('Location'),
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
                              rows: pageData.map((mkt) {
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
