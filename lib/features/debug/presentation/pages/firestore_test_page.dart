import 'package:flutter/material.dart';
import 'package:smart_agri_price_tracker/core/services/firestore_service.dart';

class FirestoreTestPage extends StatefulWidget {
  const FirestoreTestPage({super.key});

  @override
  State<FirestoreTestPage> createState() => _FirestoreTestPageState();
}

class _FirestoreTestPageState extends State<FirestoreTestPage> {
  bool? _isConnected;
  bool _isLoading = false;
  String _message = 'Press the button to test Firestore connection';

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _message = 'Testing connection...';
    });

    final success = await FirestoreService().testConnection();

    setState(() {
      _isConnected = success;
      _isLoading = false;
      _message = success 
          ? 'Successfully connected to Cloud Firestore!' 
          : 'Failed to connect to Cloud Firestore. Please check your configuration.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Connection Test'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isConnected == null 
                    ? Icons.cloud_outlined 
                    : (_isConnected! ? Icons.cloud_done : Icons.cloud_off),
                size: 80,
                color: _isConnected == null 
                    ? theme.colorScheme.primary 
                    : (_isConnected! ? Colors.green : Colors.red),
              ),
              const SizedBox(height: 24),
              Text(
                _message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 40),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: _testConnection,
                  icon: const Icon(Icons.flash_on),
                  label: const Text('Test Now'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
