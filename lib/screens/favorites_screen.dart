import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/github_repository.dart';
import '../providers/favorites_provider.dart';
import '../screens/repository_detail_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesState = ref.watch(favoritesProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.favorite_border, size: 26),
            SizedBox(width: 10),
            Text(
              'Favorites',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      body: favoritesState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Unable to load favorites.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        data: (favorites) {
          if (favorites.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 64,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No favorites yet',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Save repositories you like by tapping the heart '
                          'icon on the Explore screen.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final repo = favorites[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                clipBehavior: Clip.antiAlias,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: colorScheme.outlineVariant,
                  ),
                ),
                child: InkWell(
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
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.code,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    repo.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    repo.fullName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Remove from favorites',
                              onPressed: () {
                                ref
                                    .read(favoritesProvider.notifier)
                                    .toggleFavorite(repo);
                              },
                              icon: Icon(
                                Icons.favorite,
                                color: colorScheme.error,
                              ),
                            ),
                          ],
                        ),
                        if (repo.description != null &&
                            repo.description!.trim().isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            repo.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _FavoriteMetadata(
                              icon: Icons.star_outline,
                              label: '${repo.stars}',
                              iconColor: const Color(0xFFD29922),
                            ),
                            _FavoriteMetadata(
                              icon: Icons.call_split,
                              label: '${repo.forks}',
                            ),
                            if (repo.language != null &&
                                repo.language!.trim().isNotEmpty)
                              _FavoriteMetadata(
                                icon: Icons.circle,
                                label: repo.language!,
                                iconColor: colorScheme.primary,
                              ),
                          ],
                        ),
                      ],
                    ),
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

class _FavoriteMetadata extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;

  const _FavoriteMetadata({
    required this.icon,
    required this.label,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: iconColor ?? colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
