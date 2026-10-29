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
    final jsonList = prefs.getStringList(_storageKey) ?? [];

    return jsonList.map<GitHubRepository>((item) {
      final parts = item.split('|');
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
    }).toList();
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
      updated.map((item) {
        return [
          item.id,
          item.name,
          item.fullName,
          item.description.replaceAll('|', ' '),
          item.language,
          item.stars,
        ].join('|');
      }).toList(),
    );

    if (saved) {
      state = AsyncData(updated);
    }
  }
}
