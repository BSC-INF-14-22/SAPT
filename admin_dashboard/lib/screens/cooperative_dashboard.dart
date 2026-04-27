import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'upload_price_screen.dart';
import 'my_prices_screen.dart';
import 'admin_approval_screen.dart';

class CooperativeDashboard extends StatelessWidget {
  const CooperativeDashboard({super.key});

  Future<bool> isAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    return doc['role'] == 'admin';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        children: [
          _card(context, "Upload Prices", Icons.upload, const UploadPriceScreen()),
          _card(context, "My Prices", Icons.list, const MyPricesScreen()),
          GestureDetector(
            onTap: () async {
              if (await isAdmin()) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminApprovalScreen()));
              }
            },
            child: const Card(child: Center(child: Text("Admin Panel"))),
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, String title, IconData icon, Widget screen) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      child: Card(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 40),
          Text(title)
        ]),
      ),
    );
  }
}