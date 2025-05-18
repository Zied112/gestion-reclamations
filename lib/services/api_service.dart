import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';  // Import nécessaire pour SharedPreferences

final String baseUrl = kIsWeb
    ? "http://localhost:5000/api/users"
    : "http://10.0.2.2:5000/api/users";

class ApiService {

  // Méthode pour se connecter
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      // Si la connexion réussit, enregistrer l'email dans SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      String userEmail = responseData['email']; // Supposons que l'API renvoie l'email dans la réponse
      await prefs.setString('userEmail', userEmail); // Stocker l'email dans SharedPreferences
      return responseData;
    } else {
      return null;
    }
  }

  // Méthode pour obtenir l'email de l'utilisateur connecté
  static Future<String?> obtenirEmailUtilisateurConnecte() async {
    final prefs = await SharedPreferences.getInstance();
    // Récupérer l'email de l'utilisateur stocké dans SharedPreferences
    String? userEmail = prefs.getString('userEmail');
    return userEmail;  // Retourner l'email ou null si l'utilisateur n'est pas connecté
  }
}
