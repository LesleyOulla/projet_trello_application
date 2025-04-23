import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trello_application/models/member_model.dart';
import 'package:trello_application/service/member_service.dart';

///
class HomePage extends StatefulWidget {
  ///
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late MemberService memberService;

  void _loadMembers() async {
    final memberService = MemberService(
      apiKey: dotenv.env['TRELLO_API_KEY'] ?? '',
      apiToken: dotenv.env['TRELLO_TOKEN'] ?? '',
    );

    try {
      final members = await memberService.getMemberById('TRELLO_BOARD_ID');
      if (members != null) {
        setState(() {
          // Mettez à jour l'état avec la liste des membres
        });
        print('Membres chargés avec succès');
      } else {
        print('Erreur : Impossible de charger les membres');
      }
    } catch (e) {
      print('Erreur: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: theBar(context), // On passe le context pour la navigation
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Bienvenue sur Trell Tech !",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                _loadMembers();

                try {
                  final members = await memberService.getMembersOfBoard(
                    'TRELLO_BOARD_ID',
                  );
                  if (members != null) {
                    setState(() {
                      // Mettez à jour l'état avec la liste des membres
                    });
                    print('Membres chargés avec succès');
                  } else {
                    print('Erreur : Impossible de charger les membres');
                  }
                } catch (e) {
                  print('Erreur: $e');
                }
                context.go('/table');
              },

              child: const Text('Entrez'),
            ),
          ],
        ),
      ),
    );
  }
}

// AppBar avec un PopupMenuButton
///
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
  );
}
