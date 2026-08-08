import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/song.dart';

class LyricsSection extends StatelessWidget {
  const LyricsSection({
    super.key,
    required this.section,
    required this.index,
    required this.fontSize,
  });

  final LyricSection section;
  final int index;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final isRefrain = section.type == SectionType.refrain;

    if (isRefrain) {
      return _RefrainSection(section: section, fontSize: fontSize);
    }
    return _CoupletSection(section: section, index: index, fontSize: fontSize);
  }
}

class _CoupletSection extends StatelessWidget {
  const _CoupletSection({
    required this.section,
    required this.index,
    required this.fontSize,
  });

  final LyricSection section;
  final int index;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          'Couplet $index',
          style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)
              .copyWith(letterSpacing: 1.2),
        ),
        const SizedBox(height: 12),
        // Lignes
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

class _RefrainSection extends StatelessWidget {
  const _RefrainSection({
    required this.section,
    required this.fontSize,
  });

  final LyricSection section;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: AppColors.primaryContainer, width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label Refrain
          Row(
            children: [
              Text(
                'Refrain',
                style: AppTextStyles.labelCaps(color: AppColors.primaryContainer)
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
          // Lignes
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
