import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_explorer/navigation/main_navigation_screen.dart';
import 'package:github_explorer/screens/explore_screen.dart';

void main() {
  runApp(
      const ProviderScope(
          child: GitHubExplorerApp()
      )
  );
}

class GitHubExplorerApp extends StatelessWidget {
  const GitHubExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Github Explorer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
    );
  }
}
