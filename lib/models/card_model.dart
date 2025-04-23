class TrelloCard {
  final String cardId;
  final String name;
  final String description;
  final DateTime dueDate;
  final String label;
  final bool isCompleted;
  final String listId;
  final String boardId; // L'ID de la liste à laquelle appartient cette carte

  TrelloCard({
    required this.cardId,
    required this.name,
    required this.description,
    required this.dueDate,
    required this.label,
    required this.isCompleted,
    required this.listId,
    required this.boardId,
  });

  // Méthode de fabrication pour créer un objet TrelloCard depuis un JSON
  factory TrelloCard.fromJson(Map<String, dynamic> json) {
    return TrelloCard(
      cardId: json['id'],
      name: json['name'],
      description: json['desc'] ?? '',
      dueDate:
          json['due'] != null ? DateTime.parse(json['due']) : DateTime.now(),
      label: json['labels'].isEmpty ? 'No Label' : json['labels'][0]['name'],
      isCompleted: json['closed'] ?? false,
      listId: json['idList'],
      boardId:
          json['idBoard'] ?? '', // Assurez-vous que l'ID du tableau est présent
    );
  }
}
