import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/song.dart';

class SongCard extends StatelessWidget {
  const SongCard({
    super.key,
    required this.song,
    required this.onTap,
    this.highlightQuery = '',
  });

  final Song song;
  final VoidCallback onTap;

  /// Motif de recherche à souligner dans le titre / numéro.
  final String highlightQuery;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _HighlightedText(
                    text: song.title,
                    query: highlightQuery,
                    style: AppTextStyles.headlineMd(color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: _HighlightedText(
                    text: 'N° ${song.number}',
                    query: highlightQuery,
                    style: AppTextStyles.labelSm(
                      color: AppColors.onSecondaryContainer,
                    ).copyWith(fontWeight: FontWeight.w700, fontSize: 11),
                  ),
                ),
              ],
            ),
            if (song.firstLine.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                song.firstLine,
                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)
                    .copyWith(fontStyle: FontStyle.italic),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                if (song.theme.isNotEmpty) ...[
                  Text(
                    song.theme.toUpperCase(),
                    style: AppTextStyles.labelCaps(color: AppColors.outline),
                  ),
                  const SizedBox(width: 8),
                  const _Dot(),
                  const SizedBox(width: 8),
                ],
                if (song.key.isNotEmpty) ...[
                  Text(
                    song.key.toUpperCase(),
                    style: AppTextStyles.labelCaps(color: AppColors.outline),
                  ),
                  const SizedBox(width: 8),
                  const _Dot(),
                  const SizedBox(width: 8),
                ],
                Text(
                  song.language.code.toUpperCase(),
                  style: AppTextStyles.labelCaps(color: AppColors.outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: AppColors.outline,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Surligne la première occurrence de [query] (insensible à la casse).
class _HighlightedText extends StatelessWidget {
  const _HighlightedText({
    required this.text,
    required this.query,
    required this.style,
  });

  final String text;
  final String query;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final q = query.trim();
    if (q.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lower = text.toLowerCase();
    final lowerQ = q.toLowerCase();
    final index = lower.indexOf(lowerQ);
    if (index < 0) {
      return Text(
        text,
        style: style,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    final before = text.substring(0, index);
    final match = text.substring(index, index + q.length);
    final after = text.substring(index + q.length);

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: before, style: style),
          TextSpan(
            text: match,
            style: style.copyWith(
              backgroundColor: AppColors.secondaryContainer.withValues(alpha: 0.7),
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: after, style: style),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
