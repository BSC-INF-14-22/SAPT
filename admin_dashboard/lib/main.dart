import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'screens/auth/login_screen.dart';
import 'screens/dashboard_home.dart';
import 'screens/commodities_screen.dart';
import 'screens/markets_screen.dart';
import 'screens/prices_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SaptRootApp());
}

class SaptRootApp extends StatelessWidget {
  const SaptRootApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
      builder: (context, initSnapshot) {
        if (initSnapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(child: CircularProgressIndicator(color: Colors.black87)),
            ),
          );
        }
        if (initSnapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'Firebase Initialization Error:\n\n${initSnapshot.error}',
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }

        return const SaptAdminDashboard();
      },
    );
  }
}

class SaptAdminDashboard extends StatelessWidget {
  const SaptAdminDashboard({super.key});

  Widget _authGuard(Widget child) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.black87)),
          );
        }
        if (snapshot.hasData) {
          return child;
        }
        return const LoginScreen();
      },
    );
  }

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
      initialRoute: '/',
      routes: {
        '/': (context) => _authGuard(const DashboardHome()),
        '/dashboard': (context) => _authGuard(const DashboardHome()),
        '/commodities': (context) => _authGuard(const CommoditiesScreen()),
        '/markets': (context) => _authGuard(const MarketsScreen()),
        '/prices': (context) => _authGuard(const PricesScreen()),
      },
    );
  }
}
