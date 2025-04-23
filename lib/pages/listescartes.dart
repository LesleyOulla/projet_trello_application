import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trello_application/models/board_model.dart';
import 'package:trello_application/models/card_model.dart';
import 'package:trello_application/models/list_model.dart'; // Assurez-vous que ce fichier existe et définit TrelloList
import 'package:trello_application/service/board_service.dart';
import 'package:trello_application/service/card_service.dart';
import 'package:trello_application/service/list_service.dart';

class ListCardPage extends StatefulWidget {
  final String listId; // Déclaration du listId

  const ListCardPage({Key? key, required this.listId}) : super(key: key);

  @override
  _ListCardPageState createState() => _ListCardPageState();
}

class _ListCardPageState extends State<ListCardPage> {
  late CardService cardService;
  late BoardService boardService;
  late ListService listService;
  List<TrelloCard> _cards = [];
  TrelloList? _list;
  Board? _board;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    cardService = CardService(
      apiKey: dotenv.env['TRELLO_API_KEY'] ?? '',
      apiToken: dotenv.env['TRELLO_TOKEN'] ?? '',
    );
    boardService = BoardService(
      apiKey: dotenv.env['TRELLO_API_KEY'] ?? '',
      apiToken: dotenv.env['TRELLO_TOKEN'] ?? '',
    );
    listService = ListService(
      apiKey: dotenv.env['TRELLO_API_KEY'] ?? '',
      apiToken: dotenv.env['TRELLO_TOKEN'] ?? '',
    );
    _fetchCards();
  }

  Future<void> _fetchCards() async {
    try {
      // Récupérer les informations de la liste (ici, TrelloList)
      final TrelloList list = await listService.getListById(widget.listId);
      // Récupérer le tableau associé à la liste via listId
      final Board? board = await boardService.getBoardById(
        list.listId,
      ); // Utilisation de listId
      // Récupérer toutes les cartes associées à cette liste
      final List<TrelloCard> cards = await cardService.getCardsByListId(
        widget.listId,
      );

      setState(() {
        _list = list;
        _board = board;
        _cards = cards;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erreur lors du chargement des cartes : $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_cards.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('❌ Aucune carte trouvée')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Cartes de la liste ${_list?.name ?? ""}'),
        backgroundColor: const Color.fromARGB(255, 150, 8, 20),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: ListView.builder(
          itemCount: _cards.length,
          itemBuilder: (context, index) {
            final card = _cards[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(card.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (card.description.isNotEmpty)
                      Text('Description: ${card.description}'),
                    Text('Liste: ${_list?.name ?? "Non définie"}'),
                    Text('Tableau: ${_board?.name ?? "Non défini"}'),
                  ],
                ),
                isThreeLine: true,
                contentPadding: const EdgeInsets.all(12.0),
              ),
            );
          },
        ),
      ),
    );
  }
}
