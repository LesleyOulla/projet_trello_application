// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:trello_application/pages/home.dart';
import 'package:trello_application/pages/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  try {
    await dotenv.load();
    print("🔑 TRELLO_API_KEY: ${dotenv.env['TRELLO_API_KEY']}");
    print("🔑 TRELLO_TOKEN: ${dotenv.env['TRELLO_TOKEN']}");
  } catch (e) {
    print("⚠️ Erreur lors du chargement de .env : $e");
  }

  runApp(const MyApp());
}

// ignore: public_member_api_docs
class MyApp extends StatelessWidget {
  ///
  const MyApp({super.key});

  // Configuration du Router

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: theRoute,
      title: 'TrellTech',
      theme: ThemeData(primarySwatch: Colors.green),
    );
  }
}
