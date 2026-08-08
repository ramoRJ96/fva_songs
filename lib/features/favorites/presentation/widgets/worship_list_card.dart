import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/favorites_provider.dart';

class WorshipListCard extends StatelessWidget {
  const WorshipListCard({
    super.key,
    required this.worshipList,
    required this.onTap,
  });

  final WorshipList worshipList;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.outlineVariant.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.event_repeat,
                    color: AppColors.secondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${worshipList.songCount} CHANTS',
                    style: AppTextStyles.labelSm(
                      color: AppColors.onSurfaceVariant,
                    ).copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              worshipList.name,
              style: AppTextStyles.headlineMd(color: AppColors.onSurface),
            ),
            const SizedBox(height: 4),
            Text(
              worshipList.date,
              style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
