import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

class LyricsControllerBar extends StatelessWidget {
  const LyricsControllerBar({
    super.key,
    required this.fontSize,
    required this.onDecrease,
    required this.onIncrease,
    required this.onSanctuaryMode,
  });

  final double fontSize;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onSanctuaryMode;

  String get _sizeLabel {
    if (fontSize < 18) return 'Petite';
    if (fontSize > 26) return 'Grande';
    return 'Normale';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.95),
        border: const Border(
          top: BorderSide(color: AppColors.outlineVariant),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Contrôle A-
                _FontSizeButton(
                  label: 'A-',
                  fontSize: 18,
                  onTap: onDecrease,
                ),
                const SizedBox(width: 8),
                // Label taille
                SizedBox(
                  width: 64,
                  child: Text(
                    _sizeLabel,
                    style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 8),
                // Contrôle A+
                _FontSizeButton(
                  label: 'A+',
                  fontSize: 20,
                  onTap: onIncrease,
                ),
                // Séparateur
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    width: 1,
                    height: 40,
                    color: AppColors.outlineVariant,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: onSanctuaryMode,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.settings,
                              color: AppColors.onPrimary, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            l10n.projectionMode,
                            style: AppTextStyles.labelSm(
                                    color: AppColors.onPrimary)
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FontSizeButton extends StatelessWidget {
  const _FontSizeButton({
    required this.label,
    required this.fontSize,
    required this.onTap,
  });

  final String label;
  final double fontSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
