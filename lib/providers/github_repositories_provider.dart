import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/github_repository.dart';
import '../repositories/github_repository_api.dart';

final githubRepositoryApiProvider = Provider<GitHubRepositoryApi>((ref) {
  final api = GitHubRepositoryApi();
  ref.onDispose(api.dispose);
  return api;
});

final paginationErrorProvider = StateProvider<String?>((ref) => null);
final isLoadingMoreProvider = StateProvider<bool>((ref) => false);

final githubRepositoriesProvider =
AsyncNotifierProvider<GitHubRepositoriesNotifier,
    List<GitHubRepository>>(
  GitHubRepositoriesNotifier.new,
);

class GitHubRepositoriesNotifier
    extends AsyncNotifier<List<GitHubRepository>> {
  String _query = '';
  int _currentPage = 0;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;

  @override
  Future<List<GitHubRepository>> build() async {
    return [];
  }

  Future<void> search(String query) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      clear();
      return;
    }

    _query = trimmedQuery;
    _currentPage = 0;
    _hasMore = true;
    _isLoadingMore = false;

    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final results = await ref
          .read(githubRepositoryApiProvider)
          .searchRepositories(_query, page: 1);

      _currentPage = 1;
      _hasMore = results.length == 20;

      return results;
    });
  }

  Future<void> loadMore() async {
    ref.read(paginationErrorProvider.notifier).state = null;
    if (_isLoadingMore || !_hasMore || _query.isEmpty) return;

    final currentState = state;
    if (currentState is! AsyncData<List<GitHubRepository>>) return;

    _isLoadingMore = true;
    ref.read(isLoadingMoreProvider.notifier).state = true;
    try {
      final nextPage = _currentPage + 1;

      final results = await ref
          .read(githubRepositoryApiProvider)
          .searchRepositories(_query, page: nextPage);

      final latestState = state;
      if (latestState is! AsyncData<List<GitHubRepository>>) return;

      final existing = latestState.value;
      final existingIds = existing.map((repo) => repo.id).toSet();
      final newResults = results
          .where((repo) => !existingIds.contains(repo.id))
          .toList();

      state = AsyncData([...existing, ...newResults]);
      _currentPage = nextPage;
      _hasMore = results.length == 20;
    } catch (error) {
      ref.read(paginationErrorProvider.notifier).state =
      'Could not load more repositories. Please retry.';
      debugPrint('Failed to load more repositories: $error');
    } finally {
      _isLoadingMore = false;
      ref.read(isLoadingMoreProvider.notifier).state = false;
    }
  }

  void clear() {
    _query = '';
    _currentPage = 0;
    _hasMore = true;
    _isLoadingMore = false;
    state = const AsyncData([]);
  }
}
