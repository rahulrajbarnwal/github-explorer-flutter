import '../providers/github_repositories_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/github_repository.dart';
import '../providers/github_repositories_provider.dart';
import '../widgets/repository_list.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final searchController = TextEditingController();
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(_onScroll);
    searchController.addListener(_onSearchTextChanged);
  }

  void _onSearchTextChanged() {
    setState(() {});
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final position = scrollController.position;

    // Load the next page when the user approaches the bottom.
    if (position.pixels >= position.maxScrollExtent - 200) {
      ref.read(githubRepositoriesProvider.notifier).loadMore();
    }
  }

  Future<void> _search() async {
    FocusScope.of(context).unfocus();

    await ref
        .read(githubRepositoriesProvider.notifier)
        .search(searchController.text);
  }

  void _clearSearch() {
    searchController.clear();
    FocusScope.of(context).unfocus();

    ref.read(githubRepositoriesProvider.notifier).clear();
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchTextChanged);
    searchController.dispose();

    scrollController.removeListener(_onScroll);
    scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repositoryState = ref.watch(githubRepositoriesProvider);
    final hasResults =
        repositoryState is AsyncData<List<GitHubRepository>> &&
            repositoryState.value.isNotEmpty;
    final notifier = ref.read(githubRepositoriesProvider.notifier);
    final isLoadingMore = ref.watch(isLoadingMoreProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore GitHub'),
        actions: [
          if (searchController.text.isNotEmpty || hasResults)
            IconButton(
              tooltip: 'Clear search',
              onPressed: _clearSearch,
              icon: const Icon(Icons.clear_all),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Search Flutter, Kotlin, Android...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  tooltip: 'Clear text',
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    searchController.clear();
                    setState(() {});
                  },
                )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: repositoryState.isLoading ? null : _search,
                child: const Text('Search repositories'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: repositoryState.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stackTrace) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Unable to load repositories.'),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _search,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
                data: (repositories) {
                  if (repositories.isEmpty) {
                    return const Center(
                      child: Text(
                        'Search for repositories to get started.',
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: RepositoryList(
                          repositories: repositories,
                          scrollController: scrollController
                        ),
                      ),
                      if (isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      if (!ref.read(githubRepositoriesProvider.notifier).hasMore &&
                          repositories.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('No more repositories'),
                        ),
                      if (notifier.isLoadingMore)
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(),
                        ),
                      if (!notifier.hasMore)
                        const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('No more repositories'),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
