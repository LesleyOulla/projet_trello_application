// ignore_for_file: sort_constructors_first, public_member_api_docs

import 'package:trello_application/models/card_model.dart';

class TrelloList {
  final String listId;
  late final String name;
  final bool closed; // Indique si la liste est archivée
  List<TrelloCard>? cards;
  final String boardId;

  TrelloList({
    required this.listId,
    required this.name,
    required this.closed,
    required this.boardId,
    this.cards,
  });

  // Méthode de fabrication pour créer un objet List depuis un JSON
  factory TrelloList.fromJson(Map<String, dynamic> json) {
    return TrelloList(
      listId: json['id'],
      name: json['name'],
      closed: json['closed'],
      cards:
          (json['cards'] as List<dynamic>?)
              ?.map((cardJson) => TrelloCard.fromJson(cardJson))
              .toList(),
      boardId:
          json['idBoard'] ?? '', // Assurez-vous que l'ID du tableau est présent
    );
  }
}
