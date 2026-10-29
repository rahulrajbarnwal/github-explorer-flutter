
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

    try {
      final response = await _client.get(
        uri,
        headers: {
          'Accept': 'application/vnd.github+json',
        },
      );

      if (response.statusCode != 200) {
        throw _createApiException(response);
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
    } on GitHubApiException {
      rethrow;
    } on FormatException {
      throw GitHubApiException(
        'Invalid response received from GitHub.',
      );
    } on http.ClientException {
      throw GitHubApiException(
        'Network request failed. Please check your connection.',
      );
    }
  }

  GitHubApiException _createApiException(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode == 403 || statusCode == 429) {
      return GitHubApiException(
        'GitHub API rate limit reached. Please try again later.',
        statusCode: statusCode,
      );
    }

    if (statusCode == 404) {
      return GitHubApiException(
        'GitHub API endpoint was not found.',
        statusCode: statusCode,
      );
    }

    if (statusCode >= 500) {
      return GitHubApiException(
        'GitHub server is temporarily unavailable. Please try again.',
        statusCode: statusCode,
      );
    }

    return GitHubApiException(
      'GitHub API request failed.',
      statusCode: statusCode,
    );
  }

  void dispose() {
    _client.close();
  }
}

class GitHubApiException implements Exception {
  final String message;
  final int? statusCode;

  const GitHubApiException(
      this.message, {
        this.statusCode,
      });

  @override
  String toString() => message;
}
