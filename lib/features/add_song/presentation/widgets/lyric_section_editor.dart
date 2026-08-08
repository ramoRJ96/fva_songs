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
  });

  final SectionType type;
  final String title;
  final TextEditingController controller;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isRefrain = type == SectionType.refrain;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRefrain
            ? AppColors.surfaceContainerHighest.withOpacity(0.3)
            : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: isRefrain
            ? const Border(left: BorderSide(color: AppColors.secondary, width: 4))
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
                style: AppTextStyles.labelCaps(
                  color: isRefrain ? AppColors.secondary : AppColors.onSurfaceVariant,
                ),
              ),
              Row(
                children: [
                  if (!isRefrain)
                    const Icon(Icons.drag_indicator, size: 20, color: AppColors.onSurfaceVariant),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: AppColors.onSurfaceVariant),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: isRefrain ? 3 : 4,
            style: AppTextStyles.lyricsDisplay(color: AppColors.onSurface),
            decoration: InputDecoration(
              hintText: isRefrain
                  ? 'Saisissez les paroles du refrain...'
                  : 'Saisissez les paroles du couplet...',
              hintStyle: AppTextStyles.lyricsDisplay(
                color: AppColors.onSurfaceVariant.withOpacity(0.5),
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
