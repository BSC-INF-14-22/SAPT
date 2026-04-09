import 'package:flutter/material.dart';
import '../models/commodity_model.dart';
import '../services/commodity_service.dart';

class CommodityFormDialog extends StatefulWidget {
  final CommodityModel? existingCommodity;

  const CommodityFormDialog({super.key, this.existingCommodity});

  @override
  State<CommodityFormDialog> createState() => _CommodityFormDialogState();
}

class _CommodityFormDialogState extends State<CommodityFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _service = CommodityService();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingCommodity != null) {
      _nameController.text = widget.existingCommodity!.name;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.existingCommodity == null) {
        await _service.addCommodity(_nameController.text);
      } else {
        await _service.updateCommodity(
          widget.existingCommodity!.id, 
          _nameController.text
        );
      }
      
      if (mounted) {
        Navigator.of(context).pop(true); // Return success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
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
    final isEditMode = widget.existingCommodity != null;

    return AlertDialog(
      title: Text(
        isEditMode ? 'Edit Commodity' : 'Add New Commodity',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Commodity Name (e.g. Maize, Rice)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black87, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Commodity name is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(foregroundColor: Colors.grey.shade600),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black87,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: _isLoading 
            ? const SizedBox(
                width: 16, height: 16, 
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
              )
            : Text(isEditMode ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
