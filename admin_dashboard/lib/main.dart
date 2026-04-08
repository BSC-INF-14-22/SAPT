import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/dashboard_home.dart';

void main() {
  runApp(const SaptAdminDashboard());
}

class SaptAdminDashboard extends StatelessWidget {
  const SaptAdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAPT Admin Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF000000),
          primary: const Color(0xFF000000),
          secondary: const Color(0xFFE53935),
          tertiary: const Color(0xFF2E7D32),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const DashboardHome(),
    );
  }
}
