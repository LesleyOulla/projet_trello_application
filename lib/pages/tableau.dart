import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:trello_application/models/board_model.dart';
import 'package:trello_application/models/card_model.dart';
import 'package:trello_application/models/list_model.dart';
import 'package:trello_application/service/board_service.dart';
import 'package:trello_application/service/card_service.dart';
import 'package:trello_application/service/list_service.dart';
import 'package:trello_application/models/workspace_model.dart';
import 'package:trello_application/pages/detailscards.dart';

class TableauPage extends StatefulWidget {
  final String boardId;

  const TableauPage({super.key, required this.boardId});

  @override
  _TableauPageState createState() => _TableauPageState();
}

class _TableauPageState extends State<TableauPage> {
  Board? selectedBoard;
  late BoardService boardService;
  late ListService listService;
  late CardService cardService;

  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController boardDescController = TextEditingController();
  Map<String, TextEditingController> _cardControllers = {};
  Map<String, bool> _isAddingCardMap = {};

  bool _isAddingCard =
      false; // Variable pour afficher ou masquer la zone d'ajout de carte

  // Méthode pour ajouter une nouvelle liste
  @override
  void initState() {
    super.initState();

    boardService = BoardService(
      apiKey: dotenv.env['TRELLO_API_KEY'] ?? '',
      apiToken: dotenv.env['TRELLO_TOKEN'] ?? '',
    );
    listService = ListService(
      apiKey: dotenv.env['TRELLO_API_KEY'] ?? '',
      apiToken: dotenv.env['TRELLO_TOKEN'] ?? '',
    );
    cardService = CardService(
      apiKey: dotenv.env['TRELLO_API_KEY'] ?? '',
      apiToken: dotenv.env['TRELLO_TOKEN'] ?? '',
    );
    _loadBoardById(widget.boardId);
  }

  // Méthode pour ajouter une nouvelle liste
  void _addNewList() async {
    TextEditingController listNameController = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (BuildContext context) => AlertDialog(
            title: Text('Créer une nouvelle liste'),
            content: TextField(
              controller: listNameController,
              decoration: InputDecoration(hintText: 'Nom de la liste'),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (listNameController.text.isNotEmpty) {
                    final Map<String, dynamic>? newList = await listService
                        .createList(widget.boardId, listNameController.text);

                    if (newList != null) {
                      setState(() {
                        selectedBoard?.list?.add(
                          TrelloList(
                            listId: newList['id'],
                            name: newList['name'],
                            closed: false,
                            boardId: widget.boardId,
                            cards: <TrelloCard>[],
                          ),
                        );
                      });
                      print('✅ Liste ajoutée !');
                    }
                  }
                  Navigator.pop(context);
                },
                child: Text('Créer'),
              ),
            ],
          ),
    );
  }
  // Méthode pour charger le tableau par ID

  void _loadBoardById(String boardId) async {
    try {
      final Board? board = await boardService.getBoardById(boardId);
      _loadList(boardId);
      if (mounted) {
        setState(() {
          selectedBoard =
              board ??
              Board(
                boardId: '',
                name: 'Tableau non trouvé',
                desc: '',
                idOrganization: '',
                idEnterprise: '',
              );
        });
      }
    } catch (e) {
      print('❌ Erreur lors du chargement du tableau : $e');
    }
  }

  // Méthode pour charger les listes du tableau
  void _loadList(String boardId) async {
    final List<TrelloList> trelloList = await listService.fetchLists(boardId);
    selectedBoard?.list = trelloList;
    _loadCards();
  }

  // Méthode pour charger les cartes de chaque liste
  void _loadCards() async {
    for (TrelloList list in selectedBoard?.list ?? <TrelloList>[]) {
      final List<TrelloCard> trelloCard = await cardService.fetchCards(
        list.listId,
      ); //CHANGEMENT ICI
      if (mounted) {
        setState(() {
          list.cards = trelloCard;
        });
      }
    }
  }

  // //
  // void _openCardDetails(CardModel card) async {
  //   final result = await Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder:
  //           (_) => DetailsCardPage(
  //             cardId: card.cardId,
  //             name: card.name,
  //             initialDescription: card.description,
  //           ),
  //     ),
  //   );

  //   // ⬅️ Met à jour localement si on revient avec des données
  //   if (result != null && mounted) {
  //     setState(() {
  //       card.name = result['name'];
  //       card.description = result['description'];
  //     });
  //   }
  // }

  // Méthode pour ajouter une nouvelle carte
  void _addNewCard(String listId) async {
    final controller = _cardControllers[listId];
    if (controller != null && controller.text.isNotEmpty) {
      final newCard = await cardService.createCard(listId, controller.text);
      if (newCard != null) {
        setState(() {
          selectedBoard?.list
              ?.firstWhere((list) => list.listId == listId)
              .cards
              ?.add(newCard);
          controller.clear();
          _isAddingCardMap[listId] = false;
        });
      }
    }
  }

  // Méthode pour ajouter une nouvelle description
  void _addNewDescription(String boardId, String description) async {
    if (boardDescController.text.isNotEmpty) {
      final isSuccess = await boardService.updateBoard(
        boardId,
        description: boardDescController.text,
      );

      if (isSuccess) {
        setState(() {
          selectedBoard?.desc = boardDescController.text;
        });
      }
    }
  }

  // Méthode pour annuler l'ajout de carte
  void _cancelAddingCard() {
    setState(() {
      _isAddingCard = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: theBar(context, selectedBoard, null),
      backgroundColor: Colors.grey[300],
      body:
          selectedBoard != null && selectedBoard!.boardId.isNotEmpty
              ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      selectedBoard?.list?.map((TrelloList list) {
                        return Container(
                          width: 300,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                Colors
                                    .grey[200], // Moins gris que le fond général
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Titre de la liste
                                  Text(
                                    list.name,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              title: Text(
                                                'Supprimer cette liste ?',
                                              ),
                                              content: Text(
                                                'Cette action est irréversible.',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                  child: Text('Annuler'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    _deleteList(list.listId);
                                                    Navigator.pop(context);
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.red,
                                                      ),
                                                  child: Text('Supprimer'),
                                                ),
                                              ],
                                            ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const Divider(),
                              // Liste des cartes
                              ...?list.cards?.map((card) {
                                return GestureDetector(
                                  onTap: () {
                                    context.go('/detailscards/${card.cardId}');
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.grey[100], // Fond des cartes
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    // Affichage du nom de la carte
                                    child: Text(
                                      card.name,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                );
                              }),
                              // Zone d'ajout de carte
                              if (_isAddingCard)
                                Container(
                                  margin: const EdgeInsets.only(
                                    top: 8,
                                    bottom: 8,
                                  ),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors
                                            .grey[100], // Même fond que les cartes
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Champ de texte pour le nom de la carte
                                      TextField(
                                        controller: _cardNameController,
                                        decoration: InputDecoration(
                                          hintText: 'Nom de la carte',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          // Boutons "Annuler" et "Ajouter"
                                          TextButton(
                                            onPressed: _cancelAddingCard,
                                            child: Text(
                                              'Annuler',
                                              style: TextStyle(
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          TextButton(
                                            onPressed:
                                                () => _addNewCard(list.listId),
                                            child: Text(
                                              'Ajouter',
                                              style: TextStyle(
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              // Bouton "Ajouter une carte"
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _isAddingCard = true;
                                  });
                                },
                                icon: Icon(
                                  Icons.add,
                                  color: Colors.grey[700],
                                  size: 18,
                                ),
                                label: Text(
                                  'Ajouter une carte',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.grey[100],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList() ??
                      <Widget>[],
                ),
              )
              : const Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewList,
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _deleteList(String listId) async {
    try {
      final bool success = await listService.deleteList(listId);
      if (success) {
        setState(() {
          selectedBoard?.list?.removeWhere(
            (TrelloList list) => listId == listId, //ICI AUSSI
          );
        });
        print('✅ Liste supprimée !');
      } else {
        print('❌ Erreur lors de la suppression de la liste');
      }
    } catch (e) {
      print('❌ Erreur : $e');
    }
  }
}

AppBar theBar(BuildContext context, Board? board, Workspace? workspace) {
  return AppBar(
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          board?.name ?? 'Chargement...',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          board?.desc ?? 'Aucune description',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    ),
    backgroundColor: const Color.fromARGB(255, 71, 124, 10),
    centerTitle: true,
    leading: IconButton(
      icon: const Icon(Icons.close, color: Colors.white),
      onPressed: () {
        context.go('/table');
      },
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.filter_list, color: Colors.white),
        onPressed: () {
          print('Filtre activé');
        },
      ),
      // showDialog(
      //   context: context,
      //   builder:
      //       (BuildContext context) => AlertDialog(
      //         title: const Text('Supprimer le tableau ?'),
      //         content: const Text('Cette action est irréversible.'),
      //         actions: <Widget>[
      //           TextButton(
      //             onPressed: () => Navigator.pop(context),
      //             child: const Text('Annuler'),
      //           ),
      IconButton(
        icon: const Icon(Icons.edit, color: Colors.white),
        onPressed: () {
          context.go('/menu/${board?.boardId}');
        },
      ),
    ],
  );
}
