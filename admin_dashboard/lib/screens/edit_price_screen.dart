// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import '../services/price_service.dart';
import '../services/commodity_service.dart';
import '../services/market_service.dart';
import '../models/commodity_model.dart';
import '../models/market_model.dart';

class EditPriceScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const EditPriceScreen({super.key, required this.docId, required this.data});

  @override
  State<EditPriceScreen> createState() => _EditPriceScreenState();
}

class _EditPriceScreenState extends State<EditPriceScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _priceController;
  DateTime _selectedDate = DateTime.now();
  String? _selectedCommodityId;
  String? _selectedCommodityName;
  String? _selectedMarketId;
  String? _selectedMarketName;
  bool _isLoading = false;

  final PriceService _priceService = PriceService();
  final CommodityService _commodityService = CommodityService();
  final MarketService _marketService = MarketService();

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.data['price'].toString(),
    );
    _selectedDate =
        (widget.data['date'] as dynamic)?.toDate() ?? DateTime.now();
    _selectedCommodityId = widget.data['commodityId'];
    _selectedCommodityName = widget.data['commodityName'];
    _selectedMarketId = widget.data['marketId'];
    _selectedMarketName = widget.data['marketName'];
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCommodityId == null || _selectedMarketId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select commodity and market')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _priceService.updatePrice(
        id: widget.docId,
        commodityId: _selectedCommodityId!,
        commodityName: _selectedCommodityName!,
        marketId: _selectedMarketId!,
        marketName: _selectedMarketName!,
        price: double.parse(_priceController.text),
        date: _selectedDate,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Price')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    StreamBuilder<List<CommodityModel>>(
                      stream: _commodityService.getCommoditiesStream(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return const LinearProgressIndicator();
                        return DropdownButtonFormField<String>(
                          // ignore: deprecated_member_use
                          value: _selectedCommodityId,
                          decoration: const InputDecoration(
                            labelText: 'Commodity',
                          ),
                          items: snapshot.data!.map((c) {
                            return DropdownMenuItem(
                              value: c.id,
                              child: Text(c.name),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedCommodityId = val;
                              _selectedCommodityName = snapshot.data!
                                  .firstWhere((c) => c.id == val)
                                  .name;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    StreamBuilder<List<MarketModel>>(
                      stream: _marketService.getMarketsStream(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return const LinearProgressIndicator();
                        return DropdownButtonFormField<String>(
                          // ignore: deprecated_member_use
                          value: _selectedMarketId,
                          decoration: const InputDecoration(
                            labelText: 'Market',
                          ),
                          items: snapshot.data!.map((m) {
                            return DropdownMenuItem(
                              value: m.id,
                              child: Text(m.name),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedMarketId = val;
                              _selectedMarketName = snapshot.data!
                                  .firstWhere((m) => m.id == val)
                                  .name;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(labelText: 'Price'),
                      keyboardType: TextInputType.number,
                      validator: (val) =>
                          (val == null || val.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Date'),
                      subtitle: Text(_selectedDate.toString().split(' ')[0]),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _save,
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
