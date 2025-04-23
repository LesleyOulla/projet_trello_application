import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:trello_application/models/workspace_model.dart';

///
class WorkspaceService {
  ///
  final String apiKey;

  ///
  final String apiToken;

  WorkspaceService({required this.apiKey, required this.apiToken});

  /// 🔹 Créer un workspace (POST)
  Future<Workspace?> createWorkspace(
    String workspaceName,
    String description, {
    String permissionLevel = "private", // Ajout de la permissionLevel
  }) async {
    final url = Uri.parse(
      "https://api.trello.com/1/organizations?key=$apiKey&token=$apiToken",
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "displayName": workspaceName,
        "desc": description,
        "prefs_permissionLevel": permissionLevel, // Ajout de la permission
      }),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return Workspace.fromJson(jsonData);
    } else {
      print("❌ Erreur API: ${response.statusCode}, ${response.body}");
      return null;
    }
  }

  /// 🔹 Mettre à jour un workspace (PUT)
  Future<bool> updateWorkspace(
    String workspaceId, {
    String? workspaceName,
    String? description,
    String?
    permissionLevel, // Ajout de la possibilité de modifier la permission
  }) async {
    final url = Uri.parse(
      'https://api.trello.com/1/organizations/$workspaceId?key=$apiKey&token=$apiToken',
    );

    final response = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        if (workspaceName != null) 'displayname': workspaceName,
        if (description != null) 'desc': description,
        if (permissionLevel != null) 'prefs_permissionLevel': permissionLevel,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("❌ Erreur: ${response.statusCode} - ${response.body}");
      return false;
    }
  }

  /// 🔹 Supprimer un workspace (DELETE)
  Future<bool> deleteWorkspace(String workspaceId) async {
    final url = Uri.parse(
      'https://api.trello.com/1/organizations/$workspaceId?key=$apiKey&token=$apiToken',
    );

    final response = await http.delete(url);

    if (response.statusCode == 200) {
      return true;
    } else {
      print(
        "❌ Erreur: Impossible de supprimer le workspace (${response.statusCode})",
      );
      return false;
    }
  }
}
