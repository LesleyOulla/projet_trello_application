// import 'package:flutter/material.dart';
// import 'package:trello_application/models/workspace_model.dart';
// import 'package:trello_application/service/workspace_service.dart';

// class WorkspaceProvider with ChangeNotifier {
//   final WorkspaceService workspaceService;

//   WorkspaceProvider({required this.workspaceService});

//   List<Workspace> _workspaces = [];

//   List<Workspace> get workspaces => _workspaces;

//   Future<void> createWorkspace(String name, String desc) async {
//     final newWorkspace = await workspaceService.createWorkspace(name, desc);
//     if (newWorkspace != null) {
//       _workspaces.add(newWorkspace);
//       notifyListeners();
//     }
//   }

//   Future<void> updateWorkspace(String id, {String? name, String? desc}) async {
//     final success = await workspaceService.updateWorkspace(
//       id,
//       workspaceName: name,
//       description: desc,
//     );
//     if (success) {
//       await refresh(); // optionnel
//     }
//   }

//   Future<void> deleteWorkspace(String id) async {
//     final success = await workspaceService.deleteWorkspace(id);
//     if (success) {
//       _workspaces.removeWhere((ws) => ws.id == id);
//       notifyListeners();
//     }
//   }

//   Future<void> refresh() async {
//     // Si tu as une méthode GET ALL dans ton service, utilise-la ici
//     // Exemple : _workspaces = await workspaceService.getAllWorkspaces();
//     notifyListeners();
//   }
// }
