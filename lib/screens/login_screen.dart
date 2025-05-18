import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'manager_dashboard.dart';
import 'staff_dashboard.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _login(BuildContext context) async {
    final email = emailController.text;
    final password = passwordController.text;

    final user = await ApiService.login(email, password);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed')),
      );
      return;
    }

    if (user['role'] == 'manager') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ManagerDashboard()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => StaffDashboard()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connexion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Mot de passe'), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () => _login(context), child: Text('Se connecter')),
          ],
        ),
      ),
    );
  }
}
