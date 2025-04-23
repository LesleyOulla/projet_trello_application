import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart'; // pour debugPrint
import 'package:shared_preferences/shared_preferences.dart'; // pour SharedPreferences

import 'package:trello_application/models/board_model.dart';
import 'package:trello_application/models/card_model.dart';
import 'package:trello_application/models/list_model.dart';
import 'package:trello_application/service/card_service.dart';

///
class BoardService {
  ///
  BoardService({required this.apiKey, required this.apiToken});

  ///
  String? apiKey = dotenv.env['TRELLO_API_KEY'];

  ///
  String? apiToken = dotenv.env['TRELLO_TOKEN'];

  // recuperer un tableau par son id
  ///
  Future<Board?> getBoardById(String boardId) async {
    final url = Uri.parse(
      'https://api.trello.com/1/boards/$boardId?key=$apiKey&token=$apiToken',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Board.fromJson(data);
    } else {
      print(response.statusCode);
      throw Exception('Erreur : Impossible de charger le tableau $boardId');
    }
  }

  /// 🔹 Récupérer les tableau (GET)
  Future<List<Board>> getBoards() async {
    final url = Uri.parse(
      'https://api.trello.com/1/members/me/boards?key=$apiKey&token=$apiToken',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((board) => Board.fromJson(board)).toList();
    } else {
      throw Exception('Erreur lors du chargement des tableaux');
    }
  }

  /// 🔹 Créer un tableau (POST)
  Future<Board?> createBoard(String name, String desc) async {
    final url = Uri.parse(
      'https://api.trello.com/1/boards/?name=$name&key=$apiKey&token=$apiToken',
    );

    final response = await http.post(url);

    print("Réponse de l'API Trello: ${response.body}"); // <-- Debug

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return Board.fromJson(jsonData);
    } else {
      print('Erreur API: ${response.statusCode}, ${response.body}');
      return null;
    }
  }

  /// 🔹 Mettre à jour un tableau (PUT)
  Future<bool> updateBoard(
    String boardId, {
    String? name,
    String? description,
  }) async {
    final response = await http.put(
      Uri.parse(
        'https://api.trello.com/1/boards/$boardId?key=$apiKey&token=$apiToken',
      ),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        if (name != null) 'name': name,
        if (description != null) 'desc': description,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print(boardId);
      print('❌ Erreur: ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  /// Supprimer un tableau (DELETE)
  Future<bool> deleteBoard(String boardId) async {
    final response = await http.delete(
      Uri.parse(
        'https://api.trello.com/1/boards/$boardId?key=$apiKey&token=$apiToken',
      ),
    );

    if (response.statusCode == 200) {
      return true; // Succès
    } else {
      print(
        'Erreur: Impossible de supprimer le tableau (${response.statusCode})',
      );
      return false;
    }
  }

  /// 🔹 Récupérer les listes d'un tableau (GET)
  Future<List<Board>> getRecentBoards() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> recentBoardIds = prefs.getStringList('recentBoards') ?? [];

    List<Board> recentBoards = [];
    for (var id in recentBoardIds) {
      try {
        final board = await getBoardById(
          id,
        ); // appel direct à ta propre méthode
        if (board != null) {
          recentBoards.add(board);
        }
      } catch (e) {
        debugPrint('Erreur de chargement pour le tableau $id : $e');
      }
    }
    return recentBoards;
  }

  /// 🔹 Récupérer les listes d'un tableau (GET)
  Future<void> saveRecentBoard(String boardId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> recentBoards = prefs.getStringList('recentBoards') ?? [];

    recentBoards.remove(boardId); // Pour éviter les doublons
    recentBoards.insert(0, boardId); // Ajoute en tête de liste

    if (recentBoards.length > 10) {
      recentBoards = recentBoards.sublist(0, 10);
    }

    await prefs.setStringList('recentBoards', recentBoards);
  }

  /// Fonction pour ajouter une carte à une liste
  ///
  // Future<void> addCardToList(String listId, String name) async {
  //   TrelloCard Card = TrelloCard(
  //     name: name,
  //     cardId: 'id',
  //     description: 'description',
  //   );

  //   final url = Uri.parse(
  //     'https://api.trello.com/1/lists/$listId/cards?key=$apiKey&token=$apiToken',
  //   );

  //   final response = await http.post(url);
  //   if (response.statusCode == 200) {
  //     setState(() {
  //       selectedBoard?.list
  //           ?.firstWhere((list) => list.id == listId)
  //           .cards
  //           ?.add(
  //             TrelloCard(
  //               name: 'name',
  //               cardId: 'id',
  //               description: 'description',
  //               dueDate: DateTime.New(),
  //             ),
  //           );
  //     });
  //     print("✅ Carte ajoutée !");
  //   } else {
  //     print("❌ Erreur lors de l'ajout de la carte");
  //   }
  // }
}
