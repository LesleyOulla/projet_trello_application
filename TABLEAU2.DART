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
        _loadList(boardId);
      }
    } catch (e) {
      print('❌ Erreur lors du chargement du tableau : $e');
    }
  }

  Future<void> _loadList(String boardId) async {
    final List<TrelloList> trelloList = await listService.fetchLists(boardId);
    selectedBoard?.list = trelloList;
    _loadCards();
  }

  void _loadCards() async {
    for (TrelloList list in selectedBoard?.list ?? <TrelloList>[]) {
      final List<TrelloCard> trelloCard = await cardService.fetchCards(list.id);
      if (mounted) {
        setState(() {
          list.cards = trelloCard;
        });
      }
    }
  }

  void _deleteBoard() async {
    try {
      final bool success = await boardService.deleteBoard(widget.boardId);
      if (success) {
        Navigator.pop(context);
        context.go('/table');
      } else {
        print('❌ La suppression du tableau a échoué.');
      }
    } catch (e) {
      print('❌ Erreur lors de la suppression du tableau : $e');
    }
  }

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
                            id: newList['id'],
                            name: newList['name'],
                            closed: false,
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
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 188, 183, 183),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
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
                                  Text(
                                    list.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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
                                                    _deleteList(list.id);
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
                              Expanded(
                                child: DragTarget<TrelloCard>(
                                  onAccept: (TrelloCard draggedCard) async {
                                    final success = await cardService
                                        .updateCardList(
                                          draggedCard.cardId,
                                          list.id,
                                        );
                                    if (success) {
                                      setState(() {
                                        for (var l in selectedBoard!.list!) {
                                          l.cards?.removeWhere(
                                            (c) =>
                                                c.cardId == draggedCard.cardId,
                                          );
                                        }
                                        list.cards?.add(draggedCard);
                                      });
                                    }
                                  },
                                  builder: (
                                    context,
                                    candidateData,
                                    rejectedData,
                                  ) {
                                    return ListView.builder(
                                      itemCount: list.cards?.length,
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (
                                        BuildContext context,
                                        int index,
                                      ) {
                                        final TrelloCard? card =
                                            list.cards?[index];
                                        if (card == null)
                                          return SizedBox.shrink();

                                        return Draggable<TrelloCard>(
                                          data: card,
                                          feedback: Material(
                                            color: Colors.transparent,
                                            child: _buildCardItem(
                                              context,
                                              card,
                                            ),
                                          ),
                                          childWhenDragging: Opacity(
                                            opacity: 0.3,
                                            child: _buildCardItem(
                                              context,
                                              card,
                                            ),
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              context.go(
                                                '/details/${card.cardId}',
                                              );
                                              print(
                                                'Détails de la carte ${card.name}',
                                              );
                                            },
                                            child: _buildCardItem(
                                              context,
                                              card,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  print('Ajouter une carte à ${list.name}');
                                },
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Ajouter une carte'),
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
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildCardItem(BuildContext context, TrelloCard card) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(card.name, style: const TextStyle(fontSize: 14)),
    );
  }

  void _deleteList(String listId) async {
    try {
      final bool success = await listService.deleteList(listId);
      if (success) {
        setState(() {
          selectedBoard?.list?.removeWhere(
            (TrelloList list) => list.id == listId,
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
          workspace?.workspaceName ?? 'espace de travail de maeva',
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
      IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () {
          showDialog(
            context: context,
            builder:
                (BuildContext context) => AlertDialog(
                  title: const Text('Supprimer le tableau ?'),
                  content: const Text('Cette action est irréversible.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                  ],
                ),
          );
        },
      ),
    ],
  );
}
