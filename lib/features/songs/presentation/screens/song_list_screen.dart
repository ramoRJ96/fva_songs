import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/song_list_provider.dart';
import '../widgets/song_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/filter_chips_row.dart';

class SongListScreen extends ConsumerWidget {
  const SongListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(filteredSongListProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          // Top App Bar
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            shadowColor: Colors.black.withOpacity(0.08),
            forceElevated: true,
            leading: IconButton(
              icon: const Icon(Icons.menu, color: AppColors.primary),
              onPressed: () {},
            ),
            title: Text(
              'Sanctuary',
              style: AppTextStyles.headlineLgMobile(color: AppColors.primary),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: AppColors.primary),
                onPressed: () {},
              ),
            ],
          ),

          // Contenu scrollable
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),
                // Barre de recherche
                const SearchBarWidget(),
                const SizedBox(height: 12),
                // Filtres
                const FilterChipsRow(),
                const SizedBox(height: 24),
                // En-tête liste
                Text(
                  'Tous les Chants',
                  style: AppTextStyles.headlineMd(color: AppColors.onSurface),
                ),
                const SizedBox(height: 16),
              ]),
            ),
          ),

          // Liste de chants
          songs.isEmpty
              ? SliverFillRemaining(
                  child: _EmptyState(),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  sliver: SliverList.separated(
                    itemCount: songs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      return SongCard(
                        song: song,
                        onTap: () => context.pushNamed(
                          'song-detail',
                          pathParameters: {'id': song.id},
                          extra: {
                            'title': song.title,
                            'number': song.number,
                          },
                        ),
                      );
                    },
                  ),
                ),

          // Verset du jour
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            sliver: SliverToBoxAdapter(child: _VerseOfTheDay()),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_off_outlined,
              size: 64, color: AppColors.outlineVariant),
          const SizedBox(height: 16),
          Text(
            'Aucun chant trouvé',
            style: AppTextStyles.headlineMd(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez un autre terme ou filtre',
            style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _VerseOfTheDay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryContainer.withOpacity(0.2),
            AppColors.secondaryContainer.withOpacity(0.1),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'VERSET DU JOUR',
              style: AppTextStyles.labelCaps(color: AppColors.primary)
                  .copyWith(letterSpacing: 3.2),
            ),
            const SizedBox(height: 8),
            Text(
              '"Chantez à l\'Éternel un cantique nouveau\u00a0! Chantez à l\'Éternel, vous tous, habitants de la terre\u00a0!"',
              style: AppTextStyles.bodyLg(color: AppColors.primary)
                  .copyWith(fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '— Psaumes 96:1',
              style: AppTextStyles.labelSm(color: AppColors.outline),
            ),
          ],
        ),
      ),
    );
  }
}
