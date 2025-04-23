import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trello_application/service/board_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trello_application/service/board_service.dart';
import 'package:trello_application/models/board_model.dart';

class MenuPage extends StatefulWidget {
  final String boardId;

  const MenuPage({super.key, required this.boardId});

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  int _selectedIndex = 0;
  late BoardService boardService;
  final TextEditingController boardNameController = TextEditingController();
  final TextEditingController boardDescController = TextEditingController();
  Board? selectedBoard;

  @override
  void initState() {
    super.initState();
    boardService = BoardService(
      apiKey: dotenv.env['TRELLO_API_KEY'] ?? '',
      apiToken: dotenv.env['TRELLO_TOKEN'] ?? '',
    );
    _loadBoard();
  }

  Future<void> _loadBoard() async {
    try {
      final board = await boardService.getBoardById(widget.boardId);
      if (board != null) {
        setState(() {
          selectedBoard = board;
          boardNameController.text = board.name;
          boardDescController.text = board.desc;
        });
        print('📌 Tableau chargé avec succès');
      } else {
        print('❌ Erreur : Tableau introuvable (404)');
      }
    } catch (e) {
      print('❌ Erreur de chargement : $e');
    }
  }

  Future<void> _updateBoard() async {
    try {
      final success = await boardService.updateBoard(
        widget.boardId,
        name: boardNameController.text,
        description: boardDescController.text,
      );
      if (success) {
        print('✅ Tableau mis à jour avec succès');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Tableau mis à jour.")));
      } else {
        print('⚠️ Échec de la mise à jour');
      }
    } catch (e) {
      print('❌ Erreur lors de la mise à jour : $e');
    }
  }

  Future<void> _deleteBoard() async {
    try {
      final deleted = await boardService.deleteBoard(widget.boardId);
      if (deleted) {
        print('✅ Tableau supprimé');
        if (mounted) {
          context.go('/table');
        }
      } else {
        print('❌ Échec de la suppression');
      }
    } catch (e) {
      print('❌ Erreur de suppression : $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        context.go('/table');
        break;
      case 1:
        context.go('/mescartes');
        break;
      case 2:
        context.go('/moncompte');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: theBar(context),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => context.go('/table'),
                  child: Column(
                    children: const [
                      Icon(Icons.table_chart, size: 50),
                      Text('Tableaux'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), // Espacement

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => context.go('/mescartes'),
                  child: Column(
                    children: const [
                      Icon(Icons.credit_card, size: 50),
                      Text('Mes cartes'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), // Espacement

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => context.go('/moncompte'),
                  child: Column(
                    children: const [
                      Icon(Icons.account_circle, size: 50),
                      Text('Mon compte'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20), // Espacement
          ],
        ),
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Modifier le tableau',
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
              onPressed: _updateBoard,
              child: const Text('Modifier'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _deleteBoard,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Supprimer'),
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

AppBar theBar(BuildContext context) {
  return AppBar(
    title: const Text(
      'Trell Tech',
      style: TextStyle(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    ),
    backgroundColor: const Color.fromARGB(255, 150, 8, 20),
    centerTitle: true,
    leading: IconButton(
      icon: const Icon(Icons.close, color: Colors.white),

      onPressed: () => context.go('/table'),
    ),
  );
}
