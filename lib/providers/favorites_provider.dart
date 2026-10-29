import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/github_repository.dart';

final favoritesProvider =
AsyncNotifierProvider<FavoritesNotifier, List<GitHubRepository>>(
  FavoritesNotifier.new,
);

class FavoritesNotifier extends AsyncNotifier<List<GitHubRepository>> {
  static const _storageKey = 'favorite_repositories';

  @override
  Future<List<GitHubRepository>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final savedItems = prefs.getStringList(_storageKey) ?? [];

    final favorites = <GitHubRepository>[];

    for (final item in savedItems) {
      try {
        final decoded = jsonDecode(item);

        if (decoded is Map<String, dynamic>) {
          favorites.add(GitHubRepository.fromJson(decoded));
        } else {
          // Support the old pipe-separated storage format.
          favorites.add(_fromLegacyFormat(item));
        }
      } on FormatException {
        // Old entries aren't valid JSON; parse them using the legacy format.
        try {
          favorites.add(_fromLegacyFormat(item));
        } catch (_) {
          // Skip invalid saved entries instead of crashing the app.
        }
      } catch (_) {
        // Skip malformed entries instead of crashing the app.
      }
    }

    // Rewrite migrated entries using the new JSON format.
    await prefs.setStringList(
      _storageKey,
      favorites.map((repo) => jsonEncode(_toJson(repo))).toList(),
    );

    return favorites;
  }

  GitHubRepository _fromLegacyFormat(String item) {
    final parts = item.split('|');

    if (parts.length < 6) {
      throw const FormatException('Invalid saved favorite');
    }

    return GitHubRepository(
      id: int.parse(parts[0]),
      name: parts[1],
      fullName: parts[2],
      description: parts[3],
      language: parts[4],
      stars: int.parse(parts[5]),
      ownerAvatarUrl: '',
      htmlUrl: '',
      forks: 0,
      openIssues: 0,
      createdAt: '',
    );
  }

  Map<String, dynamic> _toJson(GitHubRepository repo) {
    return {
      'id': repo.id,
      'name': repo.name,
      'full_name': repo.fullName,
      'description': repo.description,
      'language': repo.language,
      'stargazers_count': repo.stars,
      'owner': {
        'avatar_url': repo.ownerAvatarUrl,
      },
      'html_url': repo.htmlUrl,
      'forks_count': repo.forks,
      'open_issues_count': repo.openIssues,
      'created_at': repo.createdAt,
    };
  }

  bool isFavorite(int repositoryId) {
    final currentState = state;

    return currentState is AsyncData<List<GitHubRepository>> &&
        currentState.value.any((repo) => repo.id == repositoryId);
  }

  Future<void> toggleFavorite(GitHubRepository repo) async {
    final currentState = state;

    final current = currentState is AsyncData<List<GitHubRepository>>
        ? currentState.value
        : <GitHubRepository>[];

    final updated = List<GitHubRepository>.from(current);

    if (updated.any((item) => item.id == repo.id)) {
      updated.removeWhere((item) => item.id == repo.id);
    } else {
      updated.add(repo);
    }

    final prefs = await SharedPreferences.getInstance();

    final saved = await prefs.setStringList(
      _storageKey,
      updated.map((item) => jsonEncode(_toJson(item))).toList(),
    );

    if (saved) {
      state = AsyncData(updated);
    }
  }
}
