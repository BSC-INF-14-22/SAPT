import 'package:flutter/material.dart';
import '../layouts/dashboard_layout.dart';

class PricesScreen extends StatelessWidget {
  const PricesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardLayout(
      title: 'Prices',
      currentRoute: '/prices',
      child: Center(
        child: Text(
          'Price Tracking (Coming Soon)',
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      ),
    );
  }
}
