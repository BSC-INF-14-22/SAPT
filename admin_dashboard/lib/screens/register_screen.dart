import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = AuthService();

  String email = '';
  String password = '';
  String role = 'cooperative';

  Future<void> register() async {
    final user = await _auth.register(email, password);

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': email,
        'role': role,
      });

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(onChanged: (v) => email = v, decoration: const InputDecoration(labelText: "Email")),
            TextField(onChanged: (v) => password = v, obscureText: true, decoration: const InputDecoration(labelText: "Password")),

            DropdownButton<String>(
              value: role,
              items: const [
                DropdownMenuItem(value: 'cooperative', child: Text("Cooperative")),
                DropdownMenuItem(value: 'admin', child: Text("Admin")),
              ],
              onChanged: (val) => setState(() => role = val!),
            ),

            ElevatedButton(onPressed: register, child: const Text("Register"))
          ],
        ),
      ),
    );
  }
}