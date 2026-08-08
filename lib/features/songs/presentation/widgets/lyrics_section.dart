import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/song.dart';

class LyricsSection extends StatelessWidget {
  const LyricsSection({
    super.key,
    required this.section,
    required this.fontSize,
  });

  final LyricSection section;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    switch (section.type) {
      case SectionType.refrain:
        return _HighlightedBlock(
          label: l10n.refrainLabel,
          section: section,
          fontSize: fontSize,
          accent: AppColors.primaryContainer,
        );
      case SectionType.chorus:
        return _HighlightedBlock(
          label: l10n.chorusLabel,
          section: section,
          fontSize: fontSize,
          accent: AppColors.secondary,
        );
      case SectionType.couplet:
        return _CoupletSection(
          section: section,
          label: l10n.coupletLabel(section.index ?? 0),
          fontSize: fontSize,
        );
    }
  }
}

class _CoupletSection extends StatelessWidget {
  const _CoupletSection({
    required this.section,
    required this.label,
    required this.fontSize,
  });

  final LyricSection section;
  final String label;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)
              .copyWith(letterSpacing: 1.2),
        ),
        const SizedBox(height: 12),
        ...section.lines.map(
          (line) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              line,
              style: AppTextStyles.lyricsDisplay(color: AppColors.onSurface)
                  .copyWith(fontSize: fontSize, height: 1.55),
            ),
          ),
        ),
      ],
    );
  }
}

class _HighlightedBlock extends StatelessWidget {
  const _HighlightedBlock({
    required this.label,
    required this.section,
    required this.fontSize,
    required this.accent,
  });

  final String label;
  final LyricSection section;
  final double fontSize;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: accent, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: AppTextStyles.labelCaps(color: accent)
                    .copyWith(letterSpacing: 1.2),
              ),
              if (section.isBis) ...[
                const SizedBox(width: 8),
                Text(
                  '(Bis)',
                  style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)
                      .copyWith(fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          ...section.lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                line,
                style: AppTextStyles.lyricsDisplay(color: AppColors.onSurface)
                    .copyWith(
                  fontSize: fontSize,
                  height: 1.55,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
