import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:trello_application/models/member_model.dart';

///
class MemberService {
  ///
  final String apiKey;

  ///
  final String apiToken;

  ///
  final String memberId;

  // Constructeur du service
  MemberService({
    required this.apiKey,
    required this.apiToken,
    this.memberId = '',
  });
  // : memberId = memberId ?? dotenv.env['TRELLO_MEMBER_ID'] ?? '';

  /// 🔹 Récupérer les informations d'un membre spécifique (GET)
  Future<Member?> getMemberById(String memberId) async {
    final url = Uri.parse(
      'https://api.trello.com/1/members/TRELLO_MEMBER_ID?key=$apiKey&token=$apiToken',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return Member.fromJson(jsonData);
    } else {
      print("❌ Erreur API: ${response.statusCode}, ${response.body}");
      return null;
    }
  }

  /// 🔹 Récupérer tous les membres d'un tableau (GET)
  Future<List<Member>?> getMembersOfBoard(String boardId) async {
    final url = Uri.parse(
      'https://api.trello.com/1/boards/$boardId/members?key=$apiKey&token=$apiToken',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((json) => Member.fromJson(json)).toList();
    } else {
      print("❌ Erreur API: ${response.statusCode}, ${response.body}");
      return null;
    }
  }
}
