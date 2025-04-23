// ignore_for_file: public_member_api_docs

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:trello_application/models/card_model.dart';

class CardService {
  CardService({required this.apiKey, required this.apiToken});
  String? apiKey = dotenv.env['TRELLO_API_KEY'];

  ///
  String? apiToken = dotenv.env['TRELLO_API_TOKEN'];

  /// 🔹 Récupérer toutes les cartes d'un tableau (GET)
  Future<List<TrelloCard>> fetchCards(String cardId) async {
    final http.Response response = await http.get(
      Uri.parse(
        'https://api.trello.com/1/lists/$cardId/cards?key=$apiKey&token=$apiToken',
      ),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => TrelloCard.fromJson(json)).toList();
    } else {
      print(
        'Erreur: Impossible de récupérer les cartes (${response.statusCode})',
      );
      return [];
    }
  }

  /// 🔹 Créer une carte dans une liste spécifique (POST)
  Future<TrelloCard?> createCard(
    String listId,
    String name, {
    String? description,
  }) async {
    final response = await http.post(
      Uri.parse('https://api.trello.com/1/cards?key=$apiKey&token=$apiToken'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'desc': description ?? '',
        'idList': listId,
      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return TrelloCard.fromJson(data);
    } else {
      print('Erreur: Impossible de créer la carte (${response.statusCode})');
      return null;
    }
  }

  /// 🔹 Mettre à jour une carte (PUT)
  Future<bool> updateCard(
    String cardId, {
    String? name,
    String? description,
  }) async {
    final response = await http.put(
      Uri.parse(
        'https://api.trello.com/1/cards/$cardId?key=$apiKey&token=$apiToken',
      ),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        if (name != null) 'name': name,
        if (description != null) 'desc': description,
      }),
    );

    if (response.statusCode == 200) {
      return true; // Succès
    } else {
      print(
        'Erreur: Impossible de mettre à jour la carte (${response.statusCode})',
      );
      return false;
    }
  }

  /// 🔹 Supprimer une carte (DELETE)
  Future<bool> deleteCard(String cardId) async {
    final response = await http.delete(
      Uri.parse(
        'https://api.trello.com/1/cards/$cardId?key=$apiKey&token=$apiToken',
      ),
    );

    if (response.statusCode == 200) {
      return true; // Succès
    } else {
      print(
        'Erreur: Impossible de supprimer la carte (${response.statusCode})',
      );
      return false;
    }
  }

  /// 🔹 Déplacer une carte vers une autre liste (PUT)
  Future<bool> updateCardList(String cardId, String listId) async {
    final url = Uri.parse(
      'https://api.trello.com/1/cards/$cardId?idList=$listId&key=$apiKey&token=$apiToken',
    );
    final response = await http.put(url);

    if (response.statusCode == 200) {
      return true;
    } else {
      print(
        'Erreur mise à jour carte : ${response.statusCode} ${response.body}',
      );
      return false;
    }
  }

  /// 🔹 Récupérer une carte par son ID (GET)
  Future<TrelloCard> getCardById(String cardId) async {
    final url = Uri.parse(
      'https://api.trello.com/1/cards/$cardId?key=$apiKey&token=$apiToken',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return TrelloCard.fromJson(jsonData);
    } else {
      throw Exception('Erreur lors de la récupération de la carte');
    }
  }

  /// 🔹 Mettre à jour la description d'une carte (PUT)
  Future<bool> updateCardDescription({
    required String cardId,
    required String description,
    required String name,
  }) async {
    final url = Uri.parse(
      'https://api.trello.com/1/cards/$cardId?key=$apiKey&token=$apiToken&desc=${Uri.encodeComponent(description)}',
    );

    final response = await http.put(url);
    return response.statusCode == 200;
  }

  Future<List<TrelloCard>> getCardsByListId(String listId) async {
    // Implémentation pour récupérer les cartes par ID de liste
    final response = await http.get(
      Uri.parse(
        'https://api.trello.com/1/lists/$listId/cards?key=$apiKey&token=$apiToken',
      ),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => TrelloCard.fromJson(json)).toList();
    } else {
      print("❌ Erreur API: ${response.statusCode}, ${response.body}");
      throw Exception('Erreur lors de la récupération des cartes');
    }
  }
}
