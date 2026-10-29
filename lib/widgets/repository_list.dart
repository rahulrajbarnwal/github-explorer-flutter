import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/github_repository.dart';
import '../providers/favorites_provider.dart';
import '../screens/repository_detail_screen.dart';

class RepositoryList extends ConsumerWidget {
  final List<GitHubRepository> repositories;
  final ScrollController? scrollController;

  const RepositoryList({
    super.key,
    required this.repositories,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesState = ref.watch(favoritesProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: repositories.length,
      itemBuilder: (context, index) {
        final repo = repositories[index];

        final isFavorite =
            favoritesState is AsyncData<List<GitHubRepository>> &&
                favoritesState.value.any(
                      (favorite) => favorite.id == repo.id,
                );

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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                              style: theme.textTheme.titleMedium?.copyWith(
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
                          color: isFavorite
                              ? colorScheme.error
                              : colorScheme.onSurfaceVariant,
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
                      _RepositoryMetadata(
                        icon: Icons.star_outline,
                        label: '${repo.stars}',
                        iconColor: const Color(0xFFD29922),
                      ),
                      _RepositoryMetadata(
                        icon: Icons.call_split,
                        label: '${repo.forks}',
                      ),
                      if (repo.language != null &&
                          repo.language!.trim().isNotEmpty)
                        _RepositoryMetadata(
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
  }
}

class _RepositoryMetadata extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;

  const _RepositoryMetadata({
    required this.icon,
    required this.label,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: iconColor ?? theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
