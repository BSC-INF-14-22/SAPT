import 'package:flutter/material.dart';
import '../models/price_model.dart';
import '../models/commodity_model.dart';
import '../models/market_model.dart';
import '../services/price_service.dart';
import '../services/commodity_service.dart';
import '../services/market_service.dart';

class PriceFormDialog extends StatefulWidget {
  final PriceModel? existingPrice;

  const PriceFormDialog({super.key, this.existingPrice});

  @override
  State<PriceFormDialog> createState() => _PriceFormDialogState();
}

class _PriceFormDialogState extends State<PriceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _priceService = PriceService();
  final _commodityService = CommodityService();
  final _marketService = MarketService();

  String? _selectedCommodityId;
  String? _selectedCommodityName;
  String? _selectedMarketId;
  String? _selectedMarketName;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingPrice != null) {
      _selectedCommodityId = widget.existingPrice!.commodityId;
      _selectedCommodityName = widget.existingPrice!.commodityName;
      _selectedMarketId = widget.existingPrice!.marketId;
      _selectedMarketName = widget.existingPrice!.marketName;
      _priceController.text = widget.existingPrice!.price.toString();
      _selectedDate = widget.existingPrice!.date;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCommodityId == null || _selectedMarketId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both a commodity and a market.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final price = double.parse(_priceController.text);
      if (widget.existingPrice == null) {
        await _priceService.addPrice(
          commodityId: _selectedCommodityId!,
          commodityName: _selectedCommodityName!,
          marketId: _selectedMarketId!,
          marketName: _selectedMarketName!,
          price: price,
          date: _selectedDate,
        );
      } else {
        await _priceService.updatePrice(
          id: widget.existingPrice!.id,
          commodityId: _selectedCommodityId!,
          commodityName: _selectedCommodityName!,
          marketId: _selectedMarketId!,
          marketName: _selectedMarketName!,
          price: price,
          date: _selectedDate,
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red.shade800,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.existingPrice != null;

    return AlertDialog(
      title: Text(
        isEditMode ? 'Edit Price Entry' : 'Add Price Entry',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Commodity Dropdown
                StreamBuilder<List<CommodityModel>>(
                  stream: _commodityService.getCommoditiesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LinearProgressIndicator();
                    }
                    final commodities = snapshot.data ?? [];
                    if (commodities.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'No commodities found. Add one first.',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    return DropdownButtonFormField<String>(
                      value: _selectedCommodityId,
                      decoration: const InputDecoration(labelText: 'Commodity'),
                      items: commodities.map((c) {
                        return DropdownMenuItem(
                          value: c.id,
                          child: Text(c.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCommodityId = value;
                          _selectedCommodityName = commodities.firstWhere((c) => c.id == value).name;
                        });
                      },
                      validator: (value) => value == null ? 'Required' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Market Dropdown
                StreamBuilder<List<MarketModel>>(
                  stream: _marketService.getMarketsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LinearProgressIndicator();
                    }
                    final markets = snapshot.data ?? [];
                    if (markets.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'No markets found. Add one first.',
                          style: TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    return DropdownButtonFormField<String>(
                      value: _selectedMarketId,
                      decoration: const InputDecoration(labelText: 'Market'),
                      items: markets.map((m) {
                        return DropdownMenuItem(
                          value: m.id,
                          child: Text(m.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMarketId = value;
                          _selectedMarketName = markets.firstWhere((m) => m.id == value).name;
                        });
                      },
                      validator: (value) => value == null ? 'Required' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Price Input
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price (MWK/kg)',
                    prefixText: 'MWK ',
                    suffixText: ' /kg',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    final n = double.tryParse(value);
                    if (n == null) return 'Enter a valid number';
                    if (n <= 0) return 'Price must be greater than 0';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Date Picker
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  contentPadding: EdgeInsets.zero,
                  onTap: () => _selectDate(context),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black87,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(isEditMode ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }
}
