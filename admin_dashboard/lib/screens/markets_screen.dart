import 'package:flutter/material.dart';
import '../layouts/dashboard_layout.dart';

class MarketsScreen extends StatelessWidget {
  const MarketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardLayout(
      title: 'Markets',
      currentRoute: '/markets',
      child: Center(
        child: Text(
          'Markets Management (Coming Soon)',
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      ),
    );
  }
}
