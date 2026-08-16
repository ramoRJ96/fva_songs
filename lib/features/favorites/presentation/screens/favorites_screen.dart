import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsiveness/configs/page_layout_config.dart';
import '../../../../core/responsiveness/extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../songs/domain/entities/song.dart';
import '../../../songs/presentation/providers/songs_providers.dart';
import '../widgets/favorite_song_item.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final config = context.pageConfig;
    final favoriteSongs = ref.watch(favoriteSongsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          l10n.myFavorites,
          style: AppTextStyles.headlineLgMobile(color: AppColors.primary),
        ),
        centerTitle: true,
      ),
      body: favoriteSongs.isEmpty
          ? _EmptyFavorites(l10n: l10n)
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      _contentHorizontalPadding(context, config),
                      config.verticalPadding,
                      _contentHorizontalPadding(context, config),
                      16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.savedTitles,
                          style: AppTextStyles.labelCaps(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          l10n.songsCount(favoriteSongs.length),
                          style: AppTextStyles.labelSm(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _FavoritesSliverList(
                  songs: favoriteSongs,
                  horizontalPadding: _contentHorizontalPadding(context, config),
                  crossAxisCount: config.gridCrossAxisCount,
                  childAspectRatio: config.gridChildAspectRatio,
                ),
              ],
            ),
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

class _FavoritesSliverList extends ConsumerWidget {
  const _FavoritesSliverList({
    required this.songs,
    required this.horizontalPadding,
    required this.crossAxisCount,
    required this.childAspectRatio,
  });

  final List<Song> songs;
  final double horizontalPadding;
  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          itemBuilder: (context, index) =>
              _favoriteItem(context, ref, songs[index]),
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
          (context, index) => _favoriteItem(context, ref, songs[index]),
          childCount: songs.length,
        ),
      ),
    );
  }

  Widget _favoriteItem(BuildContext context, WidgetRef ref, Song song) {
    return FavoriteSongItem(
      key: ValueKey(song.id),
      song: song,
      onTap: () => context.pushNamed(
        'song-detail',
        pathParameters: {'id': song.id},
        extra: {
          'title': song.title,
          'number': song.number,
        },
      ),
      onRemove: () {
        ref.read(favoritesControllerProvider).toggle(
              song.id,
              currentlyFavorite: true,
            );
      },
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.bookmark_outline,
              size: 64,
              color: AppColors.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.emptyFavoritesTitle,
              style: AppTextStyles.headlineMd(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.emptyFavoritesSubtitle,
              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
