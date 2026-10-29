import '../screens/repository_detail_screen.dart';
import '../models/github_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/github_repository.dart';
import '../providers/favorites_provider.dart';

class RepositoryList extends ConsumerWidget {
  final List<GitHubRepository> repositories;
  final ScrollController? scrollController;

  const RepositoryList({
    super.key,
    required this.repositories,
    this.scrollController
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final favoritesState = ref.watch(favoritesProvider);

    return ListView.builder(
      controller: scrollController,
      itemCount: repositories.length,
      itemBuilder: (context, index) {
        final repo = repositories[index];
        final isFavorite =
            favoritesState is AsyncData<List<GitHubRepository>> &&
                favoritesState.value.any((favorite) => favorite.id == repo.id);

        return Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RepositoryDetailScreen(
                      repository: repo,
                    ),
                  ),
                );
              },
          child: ListTile(
            leading: const Icon(Icons.code),
            title: Text(repo.fullName),
            subtitle: Text(
              '${repo.description}\nLanguage: ${repo.language}',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star,
                  size: 18,
                  color: Colors.amber,
                ),
                const SizedBox(width: 4),
                Text('${repo.stars}'),
                IconButton(
                  tooltip: isFavorite
                      ? 'Remove from favorites'
                      : 'Add to favorites',
                  onPressed: () {
                    ref
                        .read(favoritesProvider.notifier)
                        .toggleFavorite(repo);
                  },
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: isFavorite ? Colors.red : null,
                  ),
                ),
              ],
            ),
          ),)
        );
      },
    );
  }
}
