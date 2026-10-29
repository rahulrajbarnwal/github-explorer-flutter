class GitHubRepository {
  final int id;
  final String name;
  final String fullName;
  final String description;
  final String language;
  final int stars;
  final String ownerAvatarUrl;
  final String htmlUrl;
  final int forks;
  final int openIssues;
  final String createdAt;

  const GitHubRepository({
    required this.id,
    required this.name,
    required this.fullName,
    required this.description,
    required this.language,
    required this.stars,
    required this.ownerAvatarUrl,
    required this.htmlUrl,
    required this.forks,
    required this.openIssues,
    required this.createdAt,
  });

  factory GitHubRepository.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'] as Map<String, dynamic>? ?? {};

    return GitHubRepository(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      description: json['description'] as String? ?? 'No description',
      language: json['language'] as String? ?? 'Unknown',
      stars: json['stargazers_count'] as int? ?? 0,
      ownerAvatarUrl: owner['avatar_url'] as String? ?? '',
      htmlUrl: json['html_url'] ?? '',
      forks: json['forks_count'] ?? 0,
      openIssues: json['open_issues_count'] ?? 0,
      createdAt: json['created_at'] ?? '',
    );
  }
}
