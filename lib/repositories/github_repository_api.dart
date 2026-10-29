import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/github_repository.dart';

class GitHubRepositoryApi {
  final http.Client _client;

  GitHubRepositoryApi({http.Client? client})
      : _client = client ?? http.Client();

  Future<List<GitHubRepository>> searchRepositories(
      String query, {
        int page = 1,
        int perPage = 20,
      }) async {
    final uri = Uri.https(
      'api.github.com',
      '/search/repositories',
      {
        'q': query,
        'sort': 'stars',
        'order': 'desc',
        'per_page': '$perPage',
        'page': '$page',
      },
    );

    final response = await _client.get(
      uri,
      headers: {
        'Accept': 'application/vnd.github+json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'GitHub API request failed: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>;

    return items
        .map(
          (item) => GitHubRepository.fromJson(
        item as Map<String, dynamic>,
      ),
    )
        .toList();
  }

  void dispose() {
    _client.close();
  }
}
