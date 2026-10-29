import '../providers/github_repositories_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/github_repository.dart';
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
    final paginationError = ref.watch(paginationErrorProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.code, size: 28),
            SizedBox(width: 10),
            Text(
              'GitHub Explorer',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          if (searchController.text.isNotEmpty || hasResults)
            IconButton(
              tooltip: 'Clear search and results',
              onPressed: _clearSearch,
              icon: const Icon(Icons.clear_all),
            ),
          const SizedBox(width: 8),
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
                hintText: 'Search repositories...',
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
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: repositoryState.isLoading ? null : _search,
                icon: const Icon(Icons.search),
                label: const Text(
                  'Search repositories',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: repositoryState.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stackTrace) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.cloud_off,
                            size: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Unable to load repositories',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () {
                              final query = searchController.text.trim();
                              if (query.isNotEmpty) {
                                ref
                                    .read(githubRepositoriesProvider.notifier)
                                    .search(query);
                              }
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                data: (repositories) {
                  if (repositories.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.travel_explore,
                              size: 64,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Discover repositories',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Search GitHub to explore projects, discover new ideas, '
                                  'and find repositories built by developers worldwide.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: ['Flutter', 'Kotlin', 'Android'].map((topic) {
                                return ActionChip(
                                  label: Text(topic),
                                  onPressed: () {
                                    searchController.text = topic;
                                    _search();
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
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
                      if (paginationError != null)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                paginationError!,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: () {
                                  ref
                                      .read(paginationErrorProvider.notifier)
                                      .state = null;

                                  ref
                                      .read(githubRepositoriesProvider.notifier)
                                      .loadMore();
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry loading more'),
                              ),
                            ],
                          ),
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
