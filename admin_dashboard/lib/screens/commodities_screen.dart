import 'package:flutter/material.dart';
import '../layouts/dashboard_layout.dart';

class CommoditiesScreen extends StatelessWidget {
  const CommoditiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardLayout(
      title: 'Commodities',
      currentRoute: '/commodities',
      child: Center(
        child: Text(
          'Commodities Management (Coming Soon)',
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      ),
    );
  }
}
