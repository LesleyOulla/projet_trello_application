import 'package:flutter/material.dart';
import 'package:trello_application/models/member_model.dart';
import 'package:trello_application/service/member_service.dart';

class MemberProvider with ChangeNotifier {
  final MemberService memberService;

  MemberProvider({required this.memberService});

  Member? _member;
  List<Member>? _boardMembers;

  Member? get member => _member;
  List<Member>? get boardMembers => _boardMembers;

  Future<void> fetchMemberById(String memberId) async {
    final fetchedMember = await memberService.getMemberById(memberId);
    _member = fetchedMember;
    notifyListeners();
  }

  Future<void> fetchBoardMembers(String boardId) async {
    final fetchedMembers = await memberService.getMembersOfBoard(boardId);
    _boardMembers = fetchedMembers;
    notifyListeners();
  }
}
