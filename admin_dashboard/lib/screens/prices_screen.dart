import 'package:flutter/material.dart';
import '../layouts/dashboard_layout.dart';
import '../models/price_model.dart';
import '../models/commodity_model.dart';
import '../models/market_model.dart';
import '../services/price_service.dart';
import '../services/commodity_service.dart';
import '../services/market_service.dart';
import '../widgets/price_form_dialog.dart';
import '../widgets/search_bar.dart';
import '../widgets/pagination_controls.dart';
import '../widgets/data_table_widget.dart';

class PricesScreen extends StatefulWidget {
  const PricesScreen({super.key});

  @override
  State<PricesScreen> createState() => _PricesScreenState();
}

class _PricesScreenState extends State<PricesScreen> {
  final PriceService _priceService = PriceService();
  final CommodityService _commodityService = CommodityService();
  final MarketService _marketService = MarketService();

  // Table State
  String _searchQuery = '';
  int _sortColumnIndex = 0;
  bool _isAscending = false; // Default to newest first
  int _currentPage = 0;
  int _rowsPerPage = 10;

  // Filter State
  String? _filterCommodityId;
  String? _filterMarketId;

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

  List<PriceModel> _processData(List<PriceModel> data) {
    // 1. Filtering
    List<PriceModel> filtered = data.where((item) {
      // Search filter
      final searchLower = _searchQuery.toLowerCase();
      final matchesSearch = item.commodityName.toLowerCase().contains(searchLower) || 
                            item.marketName.toLowerCase().contains(searchLower);
      
      // Categorical filters
      final matchesCommodity = _filterCommodityId == null || item.commodityId == _filterCommodityId;
      final matchesMarket = _filterMarketId == null || item.marketId == _filterMarketId;

      return matchesSearch && matchesCommodity && matchesMarket;
    }).toList();

    // 2. Sorting
    filtered.sort((a, b) {
      int result = 0;
      switch (_sortColumnIndex) {
        case 0: // Commodity
          result = a.commodityName.compareTo(b.commodityName);
          break;
        case 1: // Market
          result = a.marketName.compareTo(b.marketName);
          break;
        case 2: // Price
          result = a.price.compareTo(b.price);
          break;
        case 3: // Date
          result = a.date.compareTo(b.date);
          break;
      }
      return _isAscending ? result : -result;
    });

    return filtered;
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

              // Search and Filter Row
              Wrap(
                spacing: 16,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  AppSearchBar(
                    hintText: 'Search by commodity or market...',
                    onChanged: (value) => setState(() {
                      _searchQuery = value;
                      _currentPage = 0;
                    }),
                  ),
                  
                  // Commodity Filter
                  StreamBuilder<List<CommodityModel>>(
                    stream: _commodityService.getCommoditiesStream(),
                    builder: (context, snapshot) {
                      final commodities = snapshot.data ?? [];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButton<String?>(
                          value: _filterCommodityId,
                          hint: const Text('All Commodities'),
                          underline: const SizedBox(),
                          items: [
                            const DropdownMenuItem<String?>(value: null, child: Text('All Commodities')),
                            ...commodities.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                          ],
                          onChanged: (val) => setState(() {
                            _filterCommodityId = val;
                            _currentPage = 0;
                          }),
                        ),
                      );
                    }
                  ),

                  // Market Filter
                  StreamBuilder<List<MarketModel>>(
                    stream: _marketService.getMarketsStream(),
                    builder: (context, snapshot) {
                      final markets = snapshot.data ?? [];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButton<String?>(
                          value: _filterMarketId,
                          hint: const Text('All Markets'),
                          underline: const SizedBox(),
                          items: [
                            const DropdownMenuItem<String?>(value: null, child: Text('All Markets')),
                            ...markets.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))),
                          ],
                          onChanged: (val) => setState(() {
                            _filterMarketId = val;
                            _currentPage = 0;
                          }),
                        ),
                      );
                    }
                  ),

                  if (_filterCommodityId != null || _filterMarketId != null || _searchQuery.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => setState(() {
                        _filterCommodityId = null;
                        _filterMarketId = null;
                        _searchQuery = '';
                        _currentPage = 0;
                      }),
                      icon: const Icon(Icons.clear_all),
                      label: const Text('Reset'),
                    ),
                ],
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
                  child: StreamBuilder<List<PriceModel>>(
                    stream: _priceService.getPricesStream(),
                    builder: (context, snapshot) {
                      final allData = snapshot.data ?? [];
                      final processedData = _processData(allData);

                      // Pagination
                      final int start = _currentPage * _rowsPerPage;
                      final int end = (start + _rowsPerPage) > processedData.length 
                          ? processedData.length 
                          : (start + _rowsPerPage);
                      final List<PriceModel> pageData = processedData.isEmpty 
                          ? [] 
                          : processedData.sublist(start, end);

                      return Column(
                        children: [
                          Expanded(
                            child: AppDataTable(
                              isLoading: snapshot.connectionState == ConnectionState.waiting,
                              columns: [
                                DataColumn(
                                  label: const Text('Commodity'),
                                  onSort: (index, ascending) => setState(() {
                                    _sortColumnIndex = index;
                                    _isAscending = ascending;
                                  }),
                                ),
                                DataColumn(
                                  label: const Text('Market'),
                                  onSort: (index, ascending) => setState(() {
                                    _sortColumnIndex = index;
                                    _isAscending = ascending;
                                  }),
                                ),
                                DataColumn(
                                  label: const Text('Price (MWK/kg)'),
                                  onSort: (index, ascending) => setState(() {
                                    _sortColumnIndex = index;
                                    _isAscending = ascending;
                                  }),
                                ),
                                DataColumn(
                                  label: const Text('Date'),
                                  onSort: (index, ascending) => setState(() {
                                    _sortColumnIndex = index;
                                    _isAscending = ascending;
                                  }),
                                ),
                                const DataColumn(label: Text('Actions')),
                              ],
                              rows: pageData.map((p) {
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
