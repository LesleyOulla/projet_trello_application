import 'package:flutter/material.dart';
import 'package:trello_application/service/board_service.dart';
import 'package:trello_application/models/board_model.dart';

class BoardProvider with ChangeNotifier {
  final BoardService _boardService;

  BoardProvider({required BoardService boardService})
    : _boardService = boardService;

  Board? _selectedBoard;
  List<Board> _boards = [];
  bool _isLoading = false;

  Board? get selectedBoard => _selectedBoard;
  List<Board> get boards => _boards;
  bool get isLoading => _isLoading;

  void setSelectedBoard(Board board) {
    _selectedBoard = board;
    notifyListeners();
  }

  Future<void> fetchBoards() async {
    _isLoading = true;
    notifyListeners();

    try {
      _boards = await _boardService.getBoards();
    } catch (e) {
      print('Erreur lors de la récupération des tableaux : $e');
      _boards = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addBoard(Board board) async {
    _boards.add(board);
    notifyListeners();
  }

  Future<void> removeBoard(String boardId) async {
    _boards.removeWhere((board) => board.boardId == boardId);
    notifyListeners();
  }
}
