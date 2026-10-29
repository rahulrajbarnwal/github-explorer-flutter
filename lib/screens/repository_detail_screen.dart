
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/github_repository.dart';
import '../providers/favorites_provider.dart';

class RepositoryDetailScreen extends ConsumerWidget {
  final GitHubRepository repository;

  const RepositoryDetailScreen({
    super.key,
    required this.repository,
  });

  Future<void> _openGitHub(BuildContext context) async {
    final url = repository.htmlUrl.trim();
    final uri = Uri.tryParse(url);

    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host != 'github.com' ||
        uri.userInfo.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A valid GitHub repository URL is unavailable.'),
        ),
      );
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open GitHub in your browser.'),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open GitHub. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final favoritesState = ref.watch(favoritesProvider);

    final isFavorite =
        favoritesState is AsyncData<List<GitHubRepository>> &&
            favoritesState.value.any(
                  (repo) => repo.id == repository.id,
            );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Repository details',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: isFavorite
                ? 'Remove from favorites'
                : 'Add to favorites',
            onPressed: () {
              ref
                  .read(favoritesProvider.notifier)
                  .toggleFavorite(repository);
            },
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? colors.error : null,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: colors.primaryContainer,
                        backgroundImage: repository.ownerAvatarUrl.isNotEmpty
                            ? NetworkImage(repository.ownerAvatarUrl)
                            : null,
                        child: repository.ownerAvatarUrl.isEmpty
                            ? Icon(
                          Icons.person_outline,
                          color: colors.onPrimaryContainer,
                          size: 30,
                        )
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              repository.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              repository.fullName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    repository.description.trim().isEmpty
                        ? 'No description available.'
                        : repository.description,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _StatCard(
                        icon: Icons.star_outline,
                        label: 'Stars',
                        value: _formatCount(repository.stars),
                        iconColor: const Color(0xFFD29922),
                      ),
                      _StatCard(
                        icon: Icons.call_split,
                        label: 'Forks',
                        value: _formatCount(repository.forks),
                      ),
                      _StatCard(
                        icon: Icons.bug_report_outlined,
                        label: 'Open issues',
                        value: _formatCount(repository.openIssues),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'About this repository',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.code,
              label: 'Language',
              value: repository.language.trim().isEmpty
                  ? 'Not specified'
                  : repository.language,
            ),
            _DetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Created',
              value: repository.createdAt.trim().isEmpty
                  ? 'Unknown'
                  : repository.createdAt.split('T').first,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: () => _openGitHub(context),
                icon: const Icon(Icons.open_in_new),
                label: const Text(
                  'Open on GitHub',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: iconColor ?? colors.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: colors.onSurfaceVariant),
      title: Text(label),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
