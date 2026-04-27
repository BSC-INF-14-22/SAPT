import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UploadPriceScreen extends StatefulWidget {
  const UploadPriceScreen({super.key});

  @override
  State<UploadPriceScreen> createState() => _UploadPriceScreenState();
}

class _UploadPriceScreenState extends State<UploadPriceScreen> {
  String crop = '', price = '', unit = '', market = '', district = '';

  Future<void> submit() async {
    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection('prices').add({
      'crop': crop,
      'price': double.parse(price),
      'unit': unit,
      'market': market,
      'district': district,
      'status': 'pending',
      'userId': user!.uid,
      'userEmail': user.email,
      'timestamp': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Price")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _input("Crop", (v) => crop = v),
            _input("Price", (v) => price = v),
            _input("Unit", (v) => unit = v),
            _input("Market", (v) => market = v),
            _input("District", (v) => district = v),
            ElevatedButton(onPressed: submit, child: const Text("Submit"))
          ],
        ),
      ),
    );
  }

  Widget _input(String label, Function(String) f) {
    return TextField(onChanged: f, decoration: InputDecoration(labelText: label));
  }
}