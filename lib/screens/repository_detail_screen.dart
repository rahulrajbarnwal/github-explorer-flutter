import '../models/github_repository.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/favorites_provider.dart';

class RepositoryDetailScreen extends ConsumerWidget {
  final GitHubRepository repository;

  const RepositoryDetailScreen({
    super.key,
    required this.repository,
  });

  Future<void> _openGitHub() async {
    final uri = Uri.tryParse(repository.htmlUrl);

    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repository Details'),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final favoritesState = ref.watch(favoritesProvider);

              final isFavorite =
                  favoritesState is AsyncData<List<GitHubRepository>> &&
                      favoritesState.value.any(
                            (repo) => repo.id == repository.id,
                      );

              return IconButton(
                tooltip: isFavorite
                    ? 'Remove from favorites'
                    : 'Add to favorites',
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                onPressed: () {
                  ref
                      .read(favoritesProvider.notifier)
                      .toggleFavorite(repository);
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundImage: repository.ownerAvatarUrl.isNotEmpty
                  ? NetworkImage(repository.ownerAvatarUrl)
                  : null,
              child: repository.ownerAvatarUrl.isEmpty
                  ? const Icon(Icons.person, size: 36)
                  : null,
            ),
            const SizedBox(height: 16),

            Text(
              repository.fullName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),

            Text(
              repository.description.isEmpty
                  ? 'No description available.'
                  : repository.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            _DetailRow(
              icon: Icons.star_outline,
              label: 'Stars',
              value: repository.stars.toString(),
            ),
            _DetailRow(
              icon: Icons.code,
              label: 'Language',
              value: repository.language.isEmpty
                  ? 'Not specified'
                  : repository.language,
            ),
            _DetailRow(
              icon: Icons.call_split,
              label: 'Forks',
              value: repository.forks.toString(),
            ),
            _DetailRow(
              icon: Icons.bug_report_outlined,
              label: 'Open issues',
              value: repository.openIssues.toString(),
            ),
            _DetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'Created',
              value: repository.createdAt.isEmpty
                  ? 'Unknown'
                  : repository.createdAt.split('T').first,
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _openGitHub,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open on GitHub'),
              ),
            ),
          ],
        ),
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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
