import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trello_application/pages/home.dart';
// import 'package:trello_application/pages/mescartes.dart';
// import 'package:trello_application/pages/moncompte.dart';
import 'package:trello_application/pages/table.dart';
import 'package:trello_application/pages/tableau.dart';
import 'package:trello_application/pages/menu.dart';
import 'package:trello_application/pages/listescartes.dart';
import 'package:trello_application/pages/detailscards.dart';

// GoRouter configuration

///
final GoRouter theRoute = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(path: '/table', builder: (context, state) => const TablePage()),

    // GoRoute(
    //   path: '/mescartes',
    //   builder: (context, state) => const MesCartesPage(),
    // ),
    GoRoute(
      path:
          '/listescartes/:listId', // Route dynamique pour charger une liste de cartes par ID
      builder: (context, state) {
        final String? listId =
            state
                .pathParameters['listId']; // Récupération de listId depuis l'URL
        if (listId == null || listId.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('❌ ID de liste manquant')),
          );
        }
        return ListCardPage(listId: listId); // Passage de listId à ListCardPage
      },
    ),

    // GoRoute(
    //   path: '/moncompte',
    //   builder: (context, state) => const MonComptePage(),
    // ),
    GoRoute(
      path: '/menu/:boardId', // Route dynamique pour charger un menu par ID
      builder: (context, state) {
        final String? boardId = state.pathParameters['boardId'];
        if (boardId == null || boardId.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('❌ ID de tableau manquant')),
          );
        }
        return MenuPage(boardId: boardId);
      },
    ),
    // Route dynamique pour charger un tableau spécifique par ID
    GoRoute(
      path: '/tableau/:id',
      builder: (context, state) {
        final String? boardId = state.pathParameters['id'];
        if (boardId == null || boardId.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text('❌ ID de tableau manquant à la page tableau'),
            ),
          );
        }

        return TableauPage(boardId: boardId);
      },
    ),
    GoRoute(
      path: '/detailscards/:id',
      builder: (context, state) {
        final String? cardId = state.pathParameters['id'];
        if (cardId == null || cardId.isEmpty) {
          return const Scaffold(
            body: Center(
              child: Text('❌ ID de carte manquant à la page détails'),
            ),
          );
        }
        return DetailsCardPage(cardId: cardId);
      },
    ),
  ],
);
