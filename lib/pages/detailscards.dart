import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:trello_application/models/board_model.dart';
import 'package:trello_application/models/card_model.dart';
import 'package:trello_application/service/card_service.dart';
import 'package:trello_application/service/board_service.dart';

class DetailsCardPage extends StatefulWidget {
  final String cardId;

  const DetailsCardPage({Key? key, required this.cardId}) : super(key: key);

  @override
  _DetailsCardPageState createState() => _DetailsCardPageState();
}

class _DetailsCardPageState extends State<DetailsCardPage> {
  late CardService cardService;
  late BoardService boardService;
  TrelloCard? _card;
  Board? _board;
  late TextEditingController _descriptionController;
  late TextEditingController _cardNameController;
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
    _cardNameController = TextEditingController();
    _descriptionController = TextEditingController();
    _fetchCardDetails();
  }

  Future<void> _fetchCardDetails() async {
    try {
      // Récupérer les détails de la carte
      final TrelloCard card = await cardService.getCardById(widget.cardId);
      // Récupérer le tableau associé en utilisant le bon champ (boardId)
      final Board? board = await boardService.getBoardById(card.boardId);

      setState(() {
        _card = card;
        _board = board;
        _descriptionController.text = card.description;
        _cardNameController.text = card.name;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erreur lors du chargement de la carte : $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateCardInfo() async {
    if (_card == null) return;

    try {
      final success = await cardService.updateCardDescription(
        cardId: widget.cardId,
        name: _cardNameController.text,
        description: _descriptionController.text,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Description mise à jour !')),
        );

        // Retour avec les nouvelles données
        Navigator.pop(context, {
          'name': _cardNameController.text,
          'description': _descriptionController.text,
        });
      } else {
        throw Exception("Échec de la mise à jour");
      }
    } catch (e) {
      print('❌ Erreur mise à jour description : $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('❌ Erreur de mise à jour')));
    }
  }

  Future<void> _deleteCard() async {
    if (_card == null) return;

    try {
      final success = await cardService.deleteCard(widget.cardId);

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('✅ Carte supprimée !')));
        Navigator.pop(context);
      } else {
        throw Exception("Échec de la suppression");
      }
    } catch (e) {
      print('❌ Erreur lors de la suppression de la carte : $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('❌ Erreur de suppression')));
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_card == null) {
      return const Scaffold(body: Center(child: Text('❌ Carte introuvable')));
    }

    return Scaffold(
      appBar: theBar(context, _board),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _cardNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nom de la carte',
              ),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Description',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _updateCardInfo,
              child: const Text('Mettre à jour la description'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _deleteCard,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        ),
      ),
    );
  }

  AppBar theBar(BuildContext context, Board? board) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 150, 8, 20),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Color.fromARGB(255, 0, 0, 0)),
        onPressed: () {
          // Utilisez l'opérateur null-aware pour accéder à board.boardId
          context.go('/tableau/${board?.boardId ?? ""}');
        },
      ),
      actions: [],
    );
  }
}
