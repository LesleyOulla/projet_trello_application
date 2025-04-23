// ignore_for_file: always_specify_types, directives_ordering, public_member_api_docs, unnecessary_lambdas
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:trello_application/models/list_model.dart';

class ListService {
  final String apiKey;
  final String apiToken;

  ListService({required this.apiKey, required this.apiToken});

  // Afficher toutes les listes d'un tableau

  Future<List<TrelloList>> fetchLists(String boardId) async {
    try {
      final http.Response response = await http.get(
        Uri.parse(
          'https://api.trello.com/1/boards/$boardId/lists?key=$apiKey&token=$apiToken',
        ),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => TrelloList.fromJson(json)).toList();
      } else {
        throw Exception(
          'Impossible de récupérer les listes (${response.statusCode})',
        );
      }
    } catch (e) {
      print('Erreur lors de la récupération des listes: $e');
      return [];
    }
  }

  // Créer une nouvelle liste
  Future<Map<String, dynamic>?> createList(
    String boardId,
    String text, {
    String? name,
    String? listId,
    String? listName,
  }) async {
    try {
      final http.Response response = await http.post(
        Uri.parse('https://api.trello.com/1/lists?key=$apiKey&token=$apiToken'),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: json.encode(<String?, String?>{'name': name, 'idBoard': boardId}),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception(
          'Impossible de créer la liste (${response.statusCode})',
        );
      }
    } catch (e) {
      print('Erreur lors de la création de la liste: $e');
      return null;
    }
  }

  // Mettre à jour une liste
  Future<bool> updateList(String listId, {String? name}) async {
    try {
      final http.Response response = await http.put(
        Uri.parse(
          'https://api.trello.com/1/lists/$listId?key=$apiKey&token=$apiToken',
        ),
        headers: <String, String>{'Content-Type': 'application/json'},
        body: json.encode(<String, String>{if (name != null) 'name': name}),
      );
      if (response.statusCode == 200) {
        return true; // Succès
      } else {
        throw Exception(
          'Impossible de mettre à jour la liste (${response.statusCode})',
        );
      }
    } catch (e) {
      print('Erreur lors de la mise à jour de la liste: $e');
      return false;
    }
  }

  // Supprimer une liste
  Future<bool> deleteList(String listId) async {
    try {
      final http.Response response = await http.delete(
        Uri.parse(
          'https://api.trello.com/1/lists/$listId/closed?/?key=$apiKey&token=$apiToken',
        ),
      );
      if (response.statusCode == 200) {
        return true; // Succès
      } else {
        throw Exception(
          'Impossible de supprimer la liste (${response.statusCode})',
        );
      }
    } catch (e) {
      print('Erreur lors de la suppression de la liste: $e');
      return false;
    }
  }

  Future<TrelloList> getListById(String listId) async {
    // Implémentation de la logique pour récupérer la liste par ID
    final response = await http.get(
      Uri.parse(
        'https://api.trello.com/1/lists/$listId?key=$apiKey&token=$apiToken',
      ),
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return TrelloList.fromJson(jsonData);
    } else {
      print("❌ Erreur API: ${response.statusCode}, ${response.body}");
      throw Exception('Erreur lors de la récupération de la liste');
    }
  }
}
