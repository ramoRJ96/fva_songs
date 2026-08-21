import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/locale_controller.dart';
import '../../../../core/responsiveness/configs/page_layout_config.dart';
import '../../../../core/responsiveness/extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/song.dart';
import '../providers/songs_providers.dart';
import '../widgets/filter_chips_row.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/song_card.dart';

class SongListScreen extends ConsumerWidget {
  const SongListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(songsCatalogProvider);
          try {
            await ref.read(songsCatalogProvider.future);
          } catch (_) {
            // L'état d'erreur est déjà géré par _SongsResults.
          }
        },
        child: CustomScrollView(
          scrollCacheExtent: const ScrollCacheExtent.pixels(480),
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: const [
            _SongsAppBar(),
            _SongsHeader(),
            _SongsResults(),
          ],
        ),
      ),
    );
  }
}

class _SongsAppBar extends ConsumerWidget {
  const _SongsAppBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return SliverAppBar(
      pinned: true,
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      forceElevated: true,
      title: Text(
        l10n.appTitle,
        style: AppTextStyles.headlineLgMobile(color: AppColors.primary),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          tooltip: l10n.aboutTitle,
          icon: const Icon(
            Icons.info_outline,
            color: AppColors.primary,
          ),
          onPressed: () => context.push('/about'),
        ),
        IconButton(
          tooltip: l10n.switchLanguage,
          icon: Text(
            ref.watch(localeControllerProvider).languageCode.toUpperCase(),
            style: AppTextStyles.labelSm(
              color: AppColors.primary,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
          onPressed: () => ref.read(localeControllerProvider.notifier).toggle(),
        ),
        IconButton(
          tooltip: l10n.adminAccess,
          icon: const Icon(
            Icons.admin_panel_settings_outlined,
            color: AppColors.primary,
          ),
          onPressed: () {
            final isAdmin = ref.read(isAdminProvider).valueOrNull ?? false;
            context.push(isAdmin ? '/admin' : '/admin/login');
          },
        ),
      ],
    );
  }
}

class _SongsHeader extends ConsumerWidget {
  const _SongsHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final config = context.pageConfig;
    final resultCount =
        ref.watch(filteredSongsProvider.select((songs) => songs.length));

    return SliverToBoxAdapter(
      child: ResponsiveContent(
        padding: EdgeInsets.symmetric(horizontal: config.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: config.verticalPadding),
            const SearchBarWidget(),
            const SizedBox(height: 12),
            const FilterChipsRow(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.allSongs,
                  style: AppTextStyles.headlineMd(color: AppColors.onSurface),
                ),
                Text(
                  l10n.resultsCount(resultCount),
                  style: AppTextStyles.labelSm(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SongsResults extends ConsumerWidget {
  const _SongsResults();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final config = context.pageConfig;
    final catalogAsync = ref.watch(songsCatalogProvider);
    final songs = ref.watch(filteredSongsProvider);
    final query = ref.watch(searchQueryProvider);

    return catalogAsync.when(
      loading: () => SliverFillRemaining(
        child: Center(child: Text(l10n.loadingSongs)),
      ),
      error: (_, _) => SliverFillRemaining(
        child: Center(child: Text(l10n.errorLoadingSongs)),
      ),
      data: (_) {
        if (songs.isEmpty) {
          return const SliverFillRemaining(child: _EmptyState());
        }
        return _SongsSliverList(
          songs: songs,
          query: query,
          horizontalPadding: _contentHorizontalPadding(context, config),
          crossAxisCount: config.gridCrossAxisCount,
          childAspectRatio: config.gridChildAspectRatio,
        );
      },
    );
  }
}

double _contentHorizontalPadding(
  BuildContext context,
  PageLayoutConfig config,
) {
  final width = MediaQuery.sizeOf(context).width;
  final maxWidth = config.maxContentWidth;
  if (maxWidth.isFinite && width > maxWidth) {
    return ((width - maxWidth) / 2).clamp(config.horizontalPadding, width);
  }
  return config.horizontalPadding;
}

/// Liste / grille à construction paresseuse (uniquement les cartes visibles).
class _SongsSliverList extends StatelessWidget {
  const _SongsSliverList({
    required this.songs,
    required this.query,
    required this.horizontalPadding,
    required this.crossAxisCount,
    required this.childAspectRatio,
  });

  final List<Song> songs;
  final String query;
  final double horizontalPadding;
  final int crossAxisCount;
  final double childAspectRatio;

  int? _indexOfKey(Key key) {
    if (key is ValueKey<String>) {
      final index = songs.indexWhere((s) => s.id == key.value);
      return index >= 0 ? index : null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.fromLTRB(
      horizontalPadding,
      0,
      horizontalPadding,
      32,
    );

    if (crossAxisCount <= 1) {
      return SliverPadding(
        padding: padding,
        sliver: SliverList.separated(
          itemCount: songs.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _songCard(context, songs[index]),
        ),
      );
    }

    return SliverPadding(
      padding: padding,
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: childAspectRatio,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _songCard(context, songs[index]),
          childCount: songs.length,
          findChildIndexCallback: _indexOfKey,
        ),
      ),
    );
  }

  Widget _songCard(BuildContext context, Song song) {
    return SongCard(
      key: ValueKey(song.id),
      song: song,
      highlightQuery: query,
      onTap: () => context.pushNamed(
        'song-detail',
        pathParameters: {'id': song.id},
        extra: {'title': song.title, 'number': song.number},
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.music_off_outlined,
            size: 64,
            color: AppColors.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.emptySongsTitle,
            style: AppTextStyles.headlineMd(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.emptySongsSubtitle,
            style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
