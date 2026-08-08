import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/services/song_filter_service.dart';
import '../providers/songs_providers.dart';

/// Chips de portée du filtre — conçues pour trouver un chant en quelques taps.
class FilterChipsRow extends ConsumerWidget {
  const FilterChipsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final active = ref.watch(searchScopeProvider);

    final filters = <(SearchScope, String)>[
      (SearchScope.all, l10n.filterAll),
      (SearchScope.title, l10n.filterTitle),
      (SearchScope.number, l10n.filterNumber),
      (SearchScope.author, l10n.filterAuthor),
      (SearchScope.theme, l10n.filterTheme),
      (SearchScope.key, l10n.filterKey),
      (SearchScope.language, l10n.filterLanguage),
      (SearchScope.favorites, l10n.filterFavorites),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (scope, label) = filters[index];
          final isActive = scope == active;
          return _FilterChip(
            label: label,
            isActive: isActive,
            onTap: () {
              ref.read(searchScopeProvider.notifier).state = scope;
            },
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(999),
          border: isActive ? null : Border.all(color: AppColors.outlineVariant),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSm(
            color: isActive ? AppColors.onPrimary : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
