import 'package:trello_application/models/list_model.dart';

///
class Board {
  ///
  final String boardId;

  ///
  final String name;

  ///
  String desc;

  ///
  final String? idOrganization; // Ajout de "?" pour gérer les valeurs null

  ///
  final String? idEnterprise;

  List<TrelloList>? list;

  Board({
    required this.boardId,
    required this.name, // Devient obligatoire
    required this.desc,
    this.idOrganization, // Peut être null
    this.idEnterprise,
  });

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      boardId: json['id'] ?? '', // Evite d'avoir un null
      name: json['name'] ?? '', // Fournit une valeur par défaut
      desc: json['desc'] ?? '', // Peut être null
      idOrganization: json['idOrganization'],
      idEnterprise: json['idEnterprise'],
    );
  }
}
