import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/locale_controller.dart';
import '../../../../core/responsiveness/extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/song.dart';
import '../providers/songs_providers.dart';
import '../widgets/filter_chips_row.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/song_card.dart';

class SongListScreen extends ConsumerWidget {
  const SongListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final config = context.pageConfig;
    final catalogAsync = ref.watch(songsCatalogProvider);
    final songs = ref.watch(filteredSongsProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
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
                tooltip: l10n.switchLanguage,
                icon: Text(
                  ref.watch(localeControllerProvider).languageCode.toUpperCase(),
                  style: AppTextStyles.labelSm(color: AppColors.primary)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                onPressed: () =>
                    ref.read(localeControllerProvider.notifier).toggle(),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: ResponsiveContent(
              padding: EdgeInsets.symmetric(
                horizontal: config.horizontalPadding,
              ),
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
                        style: AppTextStyles.headlineMd(
                          color: AppColors.onSurface,
                        ),
                      ),
                      Text(
                        l10n.resultsCount(songs.length),
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
          ),
          catalogAsync.when(
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
              return SliverToBoxAdapter(
                child: ResponsiveContent(
                  padding: EdgeInsets.fromLTRB(
                    config.horizontalPadding,
                    0,
                    config.horizontalPadding,
                    32,
                  ),
                  child: _SongsGrid(
                    songs: songs,
                    query: query,
                    crossAxisCount: config.gridCrossAxisCount,
                    childAspectRatio: config.gridChildAspectRatio,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SongsGrid extends StatelessWidget {
  const _SongsGrid({
    required this.songs,
    required this.query,
    required this.crossAxisCount,
    required this.childAspectRatio,
  });

  final List<Song> songs;
  final String query;
  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    if (crossAxisCount <= 1) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: songs.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _songCard(context, songs[index]),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: songs.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) => _songCard(context, songs[index]),
    );
  }

  Widget _songCard(BuildContext context, Song song) {
    return SongCard(
      song: song,
      highlightQuery: query,
      onTap: () => context.pushNamed(
        'song-detail',
        pathParameters: {'id': song.id},
        extra: {
          'title': song.title,
          'number': song.number,
        },
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
