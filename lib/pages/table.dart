import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trello_application/models/member_model.dart';
import 'package:trello_application/models/workspace_model.dart';
import 'package:trello_application/service/board_service.dart';
import 'package:trello_application/models/board_model.dart';
import 'package:trello_application/service/workspace_service.dart';
import 'package:trello_application/service/member_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Ajoute ceci

class TablePage extends StatefulWidget {
  const TablePage({super.key});

  @override
  _TablePageState createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  // Variables
  int _selectedIndex = 0;
  late BoardService boardService;
  late WorkspaceService workspaceService;
  late MemberService memberService;

  // Services
  Board? selectedBoard;
  Workspace? selectedWorkspace;
  Member? currentMember;

  List<Board> boardsList = [];

  final TextEditingController boardNameController = TextEditingController();
  final TextEditingController boardDescController = TextEditingController();

  // Initialisation des services
  @override
  void initState() {
    super.initState();
    boardService = BoardService(
      apiKey: dotenv.env['TRELLO_API_KEY'] ?? '',
      apiToken: dotenv.env['TRELLO_TOKEN'] ?? '',
    );
    workspaceService = WorkspaceService(
      apiKey: dotenv.env['TRELLO_API_KEY'] ?? '',
      apiToken: dotenv.env['TRELLO_TOKEN'] ?? '',
    );
    memberService = MemberService(
      apiKey: dotenv.env['TRELLO_API_KEY'] ?? '',
      apiToken: dotenv.env['TRELLO_TOKEN'] ?? '',
    );

    _loadBoards();
    _loadMember();
  }

  // Récupère les tableaux récents
  Future<List<Board>> getRecentBoards() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> recentBoardIds = prefs.getStringList('recentBoards') ?? [];

    List<Board> recentBoards = [];
    for (var id in recentBoardIds) {
      try {
        final board = await boardService.getBoardById(id);
        if (board != null) {
          recentBoards.add(board);
        }
      } catch (e) {
        print('Erreur de chargement pour le tableau $id : $e');
      }
    }
    return recentBoards;
  }

  // Sauvegarde un tableau récent
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

  // Charge les tableaux
  Future _loadBoards() async {
    final boardService = BoardService(
      apiKey: dotenv.env['TRELLO_API_KEY'],
      apiToken: dotenv.env['TRELLO_TOKEN'],
    );
    try {
      final List<Board> boards = await boardService.getBoards();
      setState(() {
        boardsList = boards;
      });
      // Enregistre le tableau récent
      if (boards.isNotEmpty) {
        await saveRecentBoard(
          boards[0].boardId,
        ); // Ajoute le premier tableau comme récent
      }
    } catch (e) {
      print('Erreur: $e');
    }
  }

  Future<void> _loadMember() async {
    final memberService = MemberService(
      apiKey: dotenv.env['TRELLO_API_KEY'] ?? '',
      apiToken: dotenv.env['TRELLO_TOKEN'] ?? '',
    );
    final String memberId = dotenv.env['TRELLO_MEMBER_ID'] ?? '';
    try {
      final members = await memberService.getMemberById(memberId);
      if (members != null) {
        setState(() {
          currentMember = members;
        });
        print('Membre chargé avec succès');
      } else {
        print('Erreur : Impossible de charger le membre');
      }
    } catch (e) {
      print('Erreur: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        context.go('/table');
        break;
      case 1:
        context.go('/listescartes');
        break;
      case 2:
        context.go('/moncompte');
        break;
    }
  }

  Future<void> _showCreateBoardForm({
    required BuildContext context,
    Function(Board?)? onBoardCreated,
  }) async {
    final TextEditingController boardNameController = TextEditingController();
    final TextEditingController boardDescController = TextEditingController();

    await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Créer un nouveau tableau',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: boardNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du tableau',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: boardDescController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final boardService = BoardService(
                    apiKey: dotenv.env['TRELLO_API_KEY'],
                    apiToken: dotenv.env['TRELLO_TOKEN'],
                  );

                  final Board? newBoard = await boardService.createBoard(
                    boardNameController.text,
                    boardDescController.text,
                  );

                  if (newBoard != null) {
                    final bool updated = await boardService.updateBoard(
                      newBoard.boardId,
                      description: boardDescController.text,
                    );

                    if (updated) {
                      print('✅ Tableau mis à jour avec succès !');
                      onBoardCreated?.call(newBoard);
                      Navigator.pop(context);
                    } else {
                      print('⚠️ Problème lors de la mise à jour du tableau.');
                    }
                  }
                },
                child: const Text('Créer'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(
        context: context,
        onCreateBoard: () {
          _showCreateBoardForm(
            context: context,
            onBoardCreated: (board) async {
              _loadBoards();
            },
          );
        },
        onEditWorkspace: () {
          // Tu peux ajouter l'édition de visibilité ici si nécessaire
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.timer_outlined, size: 25, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      'Tableaux récents',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const SizedBox(height: 10),
                FutureBuilder<List<Board>>(
                  future: getRecentBoards(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Erreur : ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text('Aucun tableau récemment consulté.');
                    } else {
                      final recentBoards = snapshot.data!;
                      return ListView.separated(
                        shrinkWrap: true, // Important pour éviter l'overflow
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recentBoards.length,
                        separatorBuilder:
                            (context, index) =>
                                Divider(color: Colors.grey[300]),
                        itemBuilder: (context, index) {
                          final board = recentBoards[index];
                          return GestureDetector(
                            onTap: () {
                              context.go('/tableau/${board.boardId}');
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 12.0,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.card_membership,
                                    color: Colors.blue,
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      board.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.person, size: 25, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  currentMember != null
                      ? 'Espace de travail de ${currentMember!.fullName}'
                      : 'Espace de travail de Maeva',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: boardsList.length,
                separatorBuilder:
                    (context, index) => Divider(color: Colors.grey[300]),
                itemBuilder: (context, index) {
                  final board = boardsList[index];

                  return GestureDetector(
                    onTap: () {
                      context.go('/tableau/${board.boardId}');
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 12.0,
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.card_membership, color: Colors.blue),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              board.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Icon(Icons.person, size: 25, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  'Espace de travail privé',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Tableau',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            label: 'Mes Cartes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Mon Compte',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

AppBar _appBar({
  required BuildContext context,
  required VoidCallback onCreateBoard,
  required VoidCallback onEditWorkspace,
}) {
  return AppBar(
    title: const Text(
      'Trello',
      style: TextStyle(
        color: Colors.white,
        fontSize: 25,
        fontWeight: FontWeight.bold,
      ),
    ),
    backgroundColor: const Color.fromARGB(255, 220, 4, 0),
    centerTitle: true,
    actions: [
      PopupMenuButton<String>(
        onSelected: (String result) {
          if (result == 'createBoard') {
            onCreateBoard.call();
          }
          if (result == 'createworkspace') {
            onEditWorkspace.call();
          }
        },
        itemBuilder:
            (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'createBoard',
                child: Text('Créer un tableau'),
              ),
              const PopupMenuItem<String>(
                value: 'createworkspace',
                child: Text('Éditer mon espace de travail'),
              ),
            ],
      ),
    ],
  );
}
