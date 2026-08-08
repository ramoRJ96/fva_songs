import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../songs/domain/entities/song.dart';

class LyricSectionEditor extends StatelessWidget {
  const LyricSectionEditor({
    super.key,
    required this.type,
    required this.title,
    required this.controller,
    required this.onDelete,
    required this.hintText,
  });

  final SectionType type;
  final String title;
  final TextEditingController controller;
  final VoidCallback onDelete;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final isRefrain = type == SectionType.refrain;
    final isChorus = type == SectionType.chorus;
    final accent = isChorus
        ? AppColors.secondary
        : isRefrain
            ? AppColors.secondary
            : AppColors.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isRefrain || isChorus)
            ? AppColors.surfaceContainerHighest.withValues(alpha: 0.3)
            : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: (isRefrain || isChorus)
            ? Border(left: BorderSide(color: accent, width: 4))
            : Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title.toUpperCase(),
                style: AppTextStyles.labelCaps(color: accent),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  size: 20,
                  color: AppColors.onSurfaceVariant,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: isRefrain || isChorus ? 3 : 4,
            style: AppTextStyles.lyricsDisplay(color: AppColors.onSurface),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTextStyles.lyricsDisplay(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
            ),
          ),
        ],
      ),
    );
  }
}
