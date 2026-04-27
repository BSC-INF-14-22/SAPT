import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminApprovalScreen extends StatelessWidget {
  const AdminApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Approve Prices")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('prices')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i];

              return ListTile(
                title: Text("${d['crop']} - ${d['price']}"),
                subtitle: Text(d['userEmail']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () => update(d.id, "approved"),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => update(d.id, "rejected"),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> update(String id, String status) async {
    await FirebaseFirestore.instance.collection('prices').doc(id).update({
      'status': status,
    });
  }
}