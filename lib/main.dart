import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_explorer/navigation/main_navigation_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: GitHubExplorerApp(),
    ),
  );
}

class GitHubExplorerApp extends StatelessWidget {
  const GitHubExplorerApp({super.key});

  static const Color githubGreen = Color(0xFF238636);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GitHub Explorer',
      themeMode: ThemeMode.system,

      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: githubGreen,
          brightness: Brightness.light,
          surface: const Color(0xFFFFFFFF),
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F8FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFFFF),
          foregroundColor: Color(0xFF1F2328),
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFFFFFFF),
          elevation: 0,
          margin: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(
              color: Color(0xFFD1D9E0),
            ),
          ),
        ),
      ),

      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3FB950),
          brightness: Brightness.dark,
          surface: const Color(0xFF161B22),
        ),
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D1117),
          foregroundColor: Color(0xFFE6EDF3),
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF161B22),
          elevation: 0,
          margin: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(
              color: Color(0xFF30363D),
            ),
          ),
        ),
      ),

      home: const MainNavigationScreen(),
    );
  }
}
