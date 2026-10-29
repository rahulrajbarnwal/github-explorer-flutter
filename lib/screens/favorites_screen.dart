
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesState = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: favoritesState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text('Unable to load favorites: $error'),
        ),
        data: (favorites) {
          if (favorites.isEmpty) {
            return const Center(
              child: Text(
                'No favorites yet. Explore and tap the heart icon.',
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final repo = favorites[index];

              return Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.code,
                    color: Colors.deepPurple,
                  ),
                  title: Text(repo.fullName),
                  subtitle: Text(
                    '${repo.description}\n'
                        'Language: ${repo.language}',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text('${repo.stars}'),
                      IconButton(
                        tooltip: 'Remove favorite',
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          ref
                              .read(favoritesProvider.notifier)
                              .toggleFavorite(repo);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
