import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/song.dart';
import '../providers/song_list_provider.dart';
import '../widgets/lyrics_section.dart';
import '../widgets/lyrics_controller_bar.dart';

class SongDetailScreen extends ConsumerStatefulWidget {
  const SongDetailScreen({
    super.key,
    required this.songId,
    required this.title,
    required this.number,
  });

  final String songId;
  final String title;
  final String number;

  @override
  ConsumerState<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends ConsumerState<SongDetailScreen> {
  double _fontSize = 22;

  static const double _minFontSize = 14;
  static const double _maxFontSize = 36;

  void _changeFontSize(double delta) {
    setState(() {
      _fontSize = (_fontSize + delta).clamp(_minFontSize, _maxFontSize);
    });
  }

  @override
  Widget build(BuildContext context) {
    final song = ref.watch(songByIdProvider(widget.songId));

    if (song == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chant introuvable')),
        body: const Center(child: Text('Ce chant n\'existe pas.')),
      );
    }

    final isFavorite = song.isFavorite;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.08),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          children: [
            Text(
              'N° ${song.number}',
              style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
            ),
            Text(
              song.title,
              style: AppTextStyles.headlineMd(color: AppColors.primary)
                  .copyWith(fontSize: 18),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Icon(
                isFavorite ? Icons.grade : Icons.grade_outlined,
                key: ValueKey(isFavorite),
                color: isFavorite
                    ? AppColors.secondaryContainer
                    : AppColors.primary,
                size: 28,
              ),
            ),
            onPressed: () {
              ref.read(songListProvider.notifier).toggleFavorite(song.id);
            },
          ),
        ],
      ),
      body: _LyricsBody(song: song, fontSize: _fontSize),
      bottomNavigationBar: LyricsControllerBar(
        fontSize: _fontSize,
        onDecrease: () => _changeFontSize(-2),
        onIncrease: () => _changeFontSize(2),
        onSanctuaryMode: () => _showSanctuaryModeSnackbar(context),
      ),
    );
  }

  void _showSanctuaryModeSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Mode Sanctuaire — bientôt disponible',
          style: AppTextStyles.labelSm(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _LyricsBody extends StatelessWidget {
  const _LyricsBody({required this.song, required this.fontSize});

  final Song song;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    // Séparer les sections : numéroter les couplets
    int coupletIndex = 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final section in song.sections) ...[
            LyricsSection(
              section: section,
              index: section.type == SectionType.couplet
                  ? ++coupletIndex
                  : 0,
              fontSize: fontSize,
            ),
            const SizedBox(height: 32),
          ],
        ],
      ),
    );
  }
}
