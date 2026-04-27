import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_price_screen.dart';

class MyPricesScreen extends StatelessWidget {
  const MyPricesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("My Prices")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('prices')
            .where('userId', isEqualTo: user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i];

              return ListTile(
                title: Text(d['crop']),
                subtitle: Text("${d['price']}"),
                trailing: Text(d['status']),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditPriceScreen(docId: d.id, data: d.data()),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}