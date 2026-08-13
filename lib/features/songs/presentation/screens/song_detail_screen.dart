import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsiveness/extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/song.dart';
import '../providers/songs_providers.dart';
import '../widgets/lyrics_controller_bar.dart';
import '../widgets/lyrics_section.dart';

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
    final l10n = AppLocalizations.of(context);
    final song = ref.watch(songByIdProvider(widget.songId));
    final isFavorite = ref.watch(isFavoriteProvider(widget.songId));

    if (song == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.songNotFound)),
        body: Center(child: Text(l10n.songDoesNotExist)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.08),
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
              style: AppTextStyles.headlineMd(
                color: AppColors.primary,
              ).copyWith(fontSize: 18),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: l10n.editSong,
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: () => context.push('/edit/${song.id}'),
          ),
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
              ref
                  .read(favoritesControllerProvider)
                  .toggle(song.id, currentlyFavorite: isFavorite);
            },
          ),
        ],
      ),
      body: _LyricsBody(song: song, fontSize: _fontSize, l10n: l10n),
      bottomNavigationBar: LyricsControllerBar(
        fontSize: _fontSize,
        onDecrease: () => _changeFontSize(-2),
        onIncrease: () => _changeFontSize(2),
        onSanctuaryMode: () => _showSanctuaryModeSnackbar(context, l10n),
      ),
    );
  }

  void _showSanctuaryModeSnackbar(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.sanctuaryModeSoon,
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
  const _LyricsBody({
    required this.song,
    required this.fontSize,
    required this.l10n,
  });

  final Song song;
  final double fontSize;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final config = context.pageConfig;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        config.horizontalPadding,
        24,
        config.horizontalPadding,
        120,
      ),
      child: ResponsiveContent(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (song.author.isNotEmpty || song.key.isNotEmpty) ...[
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  if (song.author.isNotEmpty)
                    Text(
                      '${l10n.authorLabel}: ${song.author}',
                      style: AppTextStyles.bodyMd(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  if (song.key.isNotEmpty)
                    Text(
                      '${l10n.keyLabel}: ${song.key}',
                      style: AppTextStyles.bodyMd(
                        color: AppColors.onSurfaceVariant,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                ],
              ),
              const SizedBox(height: 24),
            ],
            for (final section in song.sectionsForDisplay) ...[
              LyricsSection(section: section, fontSize: fontSize),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }
}
