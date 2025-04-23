class Workspace {
  final String workspaceId;
  final String workspaceName;
  final String description;
  final String url;
  final String logoUrl;

  Workspace({
    required this.workspaceId,
    required this.workspaceName,
    required this.description,
    required this.url,
    required this.logoUrl,
  });

  // Méthode de fabrication pour créer un objet Workspace depuis un JSON
  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      workspaceId: json['id'],
      workspaceName: json['name'],
      description: json['description'] ?? '',
      url: json['url'],
      logoUrl: json['logoUrl'] ?? '',
    );
  }
}
