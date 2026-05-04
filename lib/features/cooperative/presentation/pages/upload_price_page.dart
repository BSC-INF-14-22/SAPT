import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_agri_price_tracker/core/services/firestore_service.dart';
import 'package:smart_agri_price_tracker/core/services/auth_service.dart';

class UploadPricePage extends StatefulWidget {
  const UploadPricePage({super.key});

  @override
  State<UploadPricePage> createState() => _UploadPricePageState();
}

class _UploadPricePageState extends State<UploadPricePage> {
  final _formKey = GlobalKey<FormState>();
  final _marketController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedCrop = 'Maize';
  String _selectedUnit = 'kg';
  String _selectedDistrict = 'Lilongwe';
  bool _isLoading = false;

  final List<String> _crops = ['Maize', 'Beans', 'Rice', 'Soybeans', 'Groundnuts', 'Tobacco'];
  final List<String> _units = ['kg', '50kg bag', 'Pail (Small)', 'Pail (Large)'];
  final List<String> _districts = [
    'Lilongwe', 'Blantyre', 'Mzuzu', 'Zomba', 'Dedza', 'Kasungu', 'Mangochi', 'Salima', 'Thyolo', 'Mulanje'
  ];

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = AuthService().currentUser;
      if (user == null) throw Exception('You must be logged in to upload prices.');

      final priceData = {
        'cropName': _selectedCrop,
        'price': _priceController.text.trim(),
        'unit': _selectedUnit,
        'market': _marketController.text.trim(),
        'district': _selectedDistrict,
        'notes': _notesController.text.trim(),
        'status': 'pending',
        'uploadedBy': user.uid,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirestoreService().addData('prices', priceData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Price uploaded successfully! Waiting for approval.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload New Price'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Crop Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCrop,
                decoration: const InputDecoration(
                  labelText: 'Crop Name',
                  prefixIcon: Icon(Icons.grass),
                  border: OutlineInputBorder(),
                ),
                items: _crops.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCrop = val!),
              ),
              const SizedBox(height: 16),

              // Price Field
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price (MK)',
                  prefixIcon: Icon(Icons.monetization_on_outlined),
                  border: OutlineInputBorder(),
                  hintText: 'e.g. 500',
                ),
                keyboardType: TextInputType.number,
                validator: (value) => 
                    (value == null || value.isEmpty) ? 'Enter the current price' : null,
              ),
              const SizedBox(height: 16),

              // Unit Dropdown
              DropdownButtonFormField<String>(
                value: _selectedUnit,
                decoration: const InputDecoration(
                  labelText: 'Measurement Unit',
                  prefixIcon: Icon(Icons.scale),
                  border: OutlineInputBorder(),
                ),
                items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                onChanged: (val) => setState(() => _selectedUnit = val!),
              ),
              const SizedBox(height: 16),

              // Market Field
              TextFormField(
                controller: _marketController,
                decoration: const InputDecoration(
                  labelText: 'Market Name',
                  prefixIcon: Icon(Icons.storefront),
                  border: OutlineInputBorder(),
                  hintText: 'e.g. Lilongwe Central Market',
                ),
                validator: (value) => 
                    (value == null || value.isEmpty) ? 'Enter the market name' : null,
              ),
              const SizedBox(height: 16),

              // District Dropdown
              DropdownButtonFormField<String>(
                value: _selectedDistrict,
                decoration: const InputDecoration(
                  labelText: 'District',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(),
                ),
                items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (val) => setState(() => _selectedDistrict = val!),
              ),
              const SizedBox(height: 16),

              // Notes Field
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes',
                  prefixIcon: Icon(Icons.note_alt_outlined),
                  border: OutlineInputBorder(),
                  hintText: 'e.g. High supply today',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text(
                        'SUBMIT PRICE', 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _marketController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
