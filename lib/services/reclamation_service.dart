import 'dart:convert';
import 'package:http/http.dart' as http;
import '../screens/reclamation.dart';
import 'package:flutter/foundation.dart';  // Pour vérifier la plateforme

class ReclamationService {
  // Fonction pour obtenir l'URL de base selon la plateforme
  static String getBaseUrl() {
    if (kIsWeb) {
      // Si l'application tourne sur le Web, on peut utiliser localhost
      return 'http://localhost:5000';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // Si l'application tourne sur un émulateur iOS, localhost fonctionne
      return 'http://localhost:5000';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // Si l'application tourne sur un émulateur Android
      return 'http://10.0.2.2:5000';
    } else {
      // Par défaut, sur un appareil physique, utiliser l'IP locale
      return 'http://192.168.1.100:5000';  // Remplacez par l'IP de votre machine
    }
  }


  // Méthode pour récupérer les réclamations
  static Future<List<Reclamation>> getReclamations() async {
    final baseUrl = getBaseUrl();
    final response = await http.get(Uri.parse('$baseUrl/api/reclamations'));

    print('GET Reclamations response code: ${response.statusCode}');
    print('GET Reclamations response body: ${response.body}');

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        List<dynamic> data = json.decode(response.body);
        print('Reclamations count: ${data.length}');
        return data.map((e) => Reclamation.fromJson(e)).toList();
      } else {
        throw Exception('Réponse vide de l\'API');
      }
    } else {
      throw Exception('Failed to load reclamations');
    }
  }



  // Méthode pour créer une réclamation
  static Future<void> createReclamation(Reclamation reclamation) async {
    final baseUrl = getBaseUrl();

    // Vérifie si la réclamation est valide
    if (reclamation == null) {
      throw Exception('La réclamation ne peut pas être nulle');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/reclamations/create'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(reclamation.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create reclamation');
    }
  }

  // Méthode pour modifier une réclamation
  static Future<void> updateReclamation(Reclamation reclamation) async {
    final baseUrl = getBaseUrl();

    // Assure-toi que l'ID de la réclamation est présent
    if (reclamation.id == null) {
      throw Exception('La réclamation doit avoir un ID pour être modifiée');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/api/reclamations/update/${reclamation.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(reclamation.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Échec de la modification de la réclamation');
    }
  }
// Méthode pour mettre à jour uniquement le status d'une réclamation
  static Future<void> updateReclamationStatus(String id, String status) async {
    final baseUrl = getBaseUrl();

    final response = await http.put(
      Uri.parse('$baseUrl/api/reclamations/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'status': status}),
    );

    if (response.statusCode != 200) {
      throw Exception('Échec de la mise à jour du statut');
    }
  }

  // Méthode pour supprimer une réclamation
  static Future<void> deleteReclamation(String id) async {
    final baseUrl = getBaseUrl();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/reclamations/$id'),
    );
    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la suppression de la réclamation');
    }
  }
}
