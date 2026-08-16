import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/add_song/presentation/screens/add_song_screen.dart';
import '../../features/auth/presentation/screens/admin_login_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/moderation/presentation/screens/moderation_screen.dart';
import '../../features/songs/presentation/providers/songs_providers.dart';
import '../../features/songs/presentation/screens/song_detail_screen.dart';
import '../../features/songs/presentation/screens/song_list_screen.dart';
import '../../l10n/app_localizations.dart';
import '../responsiveness/extensions.dart';
import '../theme/app_colors.dart';

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => _ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'songs',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SongListScreen(),
            ),
          ),
          GoRoute(
            path: '/favorites',
            name: 'favorites',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FavoritesScreen(),
            ),
          ),
          GoRoute(
            path: '/add',
            name: 'add-song',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AddSongScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/song/:id',
        name: 'song-detail',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final extra = state.extra as Map<String, dynamic>?;
          return SongDetailScreen(
            songId: id,
            title: extra?['title'] as String? ?? '',
            number: extra?['number'] as String? ?? '',
          );
        },
      ),
      GoRoute(
        path: '/edit/:id',
        name: 'edit-song',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return _EditSongRoute(songId: id);
        },
      ),
      GoRoute(
        path: '/admin/login',
        name: 'admin-login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin-moderation',
        builder: (context, state) => const ModerationScreen(),
      ),
    ],
  );
}

class _EditSongRoute extends ConsumerWidget {
  const _EditSongRoute({required this.songId});

  final String songId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final songAsync = ref.watch(songDetailProvider(songId));

    return songAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.loadingSongs)),
        body: Center(child: Text(l10n.loadingSongs)),
      ),
      error: (_, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.songNotFound)),
        body: Center(child: Text(l10n.errorLoadingSongs)),
      ),
      data: (song) {
        if (song == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.songNotFound)),
            body: Center(child: Text(l10n.songDoesNotExist)),
          );
        }
        return AddSongScreen(editingSong: song);
      },
    );
  }
}

class _ShellScaffold extends StatelessWidget {
  const _ShellScaffold({required this.child});
  final Widget child;

  int _locationToIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/favorites')) return 1;
    if (location.startsWith('/add')) return 2;
    return 0;
  }

  void _go(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
      case 1:
        context.go('/favorites');
      case 2:
        context.go('/add');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selectedIndex = _locationToIndex(context);
    final useRail = context.pageConfig.useNavigationRail;

    if (useRail) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: (index) => _go(context, index),
              backgroundColor: AppColors.surface,
              indicatorColor: AppColors.secondaryContainer,
              labelType: NavigationRailLabelType.all,
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.search_outlined),
                  selectedIcon: const Icon(Icons.search),
                  label: Text(l10n.navSongs),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.bookmark_outline),
                  selectedIcon: const Icon(Icons.bookmark),
                  label: Text(l10n.navFavorites),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.add_circle_outline),
                  selectedIcon: const Icon(Icons.add_circle),
                  label: Text(l10n.navAdd),
                ),
              ],
            ),
            const VerticalDivider(width: 1, color: AppColors.outlineVariant),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => _go(context, index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.search_outlined),
            selectedIcon: const Icon(Icons.search),
            label: l10n.navSongs,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bookmark_outline),
            selectedIcon: const Icon(Icons.bookmark),
            label: l10n.navFavorites,
          ),
          NavigationDestination(
            icon: const Icon(Icons.add_circle_outline),
            selectedIcon: const Icon(Icons.add_circle),
            label: l10n.navAdd,
          ),
        ],
      ),
    );
  }
}
