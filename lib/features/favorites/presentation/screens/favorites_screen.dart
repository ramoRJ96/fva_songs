import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../songs/presentation/providers/song_list_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/favorite_song_item.dart';
import '../widgets/worship_list_card.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favoriteSongs = ref.watch(favoriteSongsProvider);
    final worshipLists = ref.watch(worshipListsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.primary),
          onPressed: () {},
        ),
        title: Text(
          'Mes Favoris',
          style: AppTextStyles.headlineLgMobile(color: AppColors.primary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Tab bar personnalisé
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.onSecondaryContainer,
                unselectedLabelColor: AppColors.onSurfaceVariant,
                labelStyle: AppTextStyles.labelSm().copyWith(fontWeight: FontWeight.bold),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Favoris'),
                  Tab(text: 'Listes de Culte'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // TabBarView Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Onglet 1: Favoris
                _FavoritesTabContent(favoriteSongs: favoriteSongs),
                // Onglet 2: Listes de Culte
                _WorshipListsTabContent(worshipLists: worshipLists),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoritesTabContent extends ConsumerWidget {
  const _FavoritesTabContent({required this.favoriteSongs});

  final List favoriteSongs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (favoriteSongs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bookmark_outline, size: 64, color: AppColors.outlineVariant),
            const SizedBox(height: 16),
            Text(
              'Aucun favori pour le moment',
              style: AppTextStyles.headlineMd(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez des chants à vos favoris en cliquant sur l\'étoile.',
              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TITRES ENREGISTRÉS',
              style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant),
            ),
            Text(
              '${favoriteSongs.length} chants',
              style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: favoriteSongs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final song = favoriteSongs[index];
            return FavoriteSongItem(
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
                ref.read(songListProvider.notifier).toggleFavorite(song.id);
              },
            );
          },
        ),
        const SizedBox(height: 24),
        // Discovery Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DÉCOUVRIR PLUS',
                    style: AppTextStyles.labelCaps(color: AppColors.onPrimaryContainer.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Besoin d\'inspiration ?',
                    style: AppTextStyles.headlineMd(color: AppColors.onPrimaryContainer),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explorez les chants les plus populaires de la semaine pour enrichir vos listes.',
                    style: AppTextStyles.bodyMd(color: AppColors.onPrimaryContainer.withOpacity(0.9)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.onPrimaryContainer,
                      foregroundColor: AppColors.primaryContainer,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    onPressed: () {},
                    child: Text(
                      'Explorer',
                      style: AppTextStyles.labelSm(color: AppColors.primaryContainer).copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  Icons.auto_awesome,
                  size: 120,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _WorshipListsTabContent extends StatelessWidget {
  const _WorshipListsTabContent({required this.worshipLists});

  final List worshipLists;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MES PRÉPARATIONS',
              style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
              label: Text(
                'Nouvelle liste',
                style: AppTextStyles.labelSm(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: worshipLists.length - 1,
          itemBuilder: (context, index) {
            final item = worshipLists[index];
            return WorshipListCard(
              worshipList: item,
              onTap: () {},
            );
          },
        ),
        const SizedBox(height: 24),
        // Liste en cours (Bento)
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LISTE EN COURS',
                  style: AppTextStyles.labelCaps(color: AppColors.secondary),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dimanche Prochain',
                          style: AppTextStyles.headlineLgMobile(color: AppColors.primary),
                        ),
                        Text(
                          '24 Mars 2024 • 10:30',
                          style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                      ),
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const _PlaylistItem(index: '1', title: 'Levez-vous, cœurs fidèles'),
                const Divider(),
                const _PlaylistItem(index: '2', title: 'Je louerai l\'Éternel'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _PlaylistItem extends StatelessWidget {
  const _PlaylistItem({required this.index, required this.title});

  final String index;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            index,
            style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant).copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyMd(color: AppColors.onSurface),
            ),
          ),
          const Icon(Icons.drag_handle, color: AppColors.onSurfaceVariant, size: 20),
        ],
      ),
    );
  }
}
