///
class Member {
  ///
  final String memberId;

  ///
  final String fullName;

  ///
  final String username;

  ///
  final String avatarUrl;

  Member({
    required this.memberId,
    required this.fullName,
    required this.username,
    required this.avatarUrl,
  });

  // Méthode de fabrication pour créer un objet Member depuis un JSON
  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      memberId: json['id'],
      fullName: json['fullName'],
      username: json['username'],
      avatarUrl: json['avatarUrl'],
    );
  }
}
