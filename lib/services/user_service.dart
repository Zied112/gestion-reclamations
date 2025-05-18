import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class UserService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5000';
    // ... adapte selon la plateforme
    return 'http://10.0.2.2:5000';
  }

  static Future<List<dynamic>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/api/users/get'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur lors du chargement des utilisateurs');
    }
  }

  static Future<void> deleteUser(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/api/users/$id'));
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression');
    }
  }

  // Ajoute createUser, updateUser si besoin
} 