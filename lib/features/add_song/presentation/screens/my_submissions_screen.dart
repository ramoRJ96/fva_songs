import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/responsiveness/extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../songs/domain/entities/song_submission.dart';
import '../../../songs/presentation/providers/songs_providers.dart';

class MySubmissionsScreen extends ConsumerWidget {
  const MySubmissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final submissionsAsync = ref.watch(mySubmissionsProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          l10n.mySubmissionsTitle,
          style: AppTextStyles.headlineMd(color: AppColors.primary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.canPop() ? context.pop() : context.go('/add'),
        ),
      ),
      body: submissionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.history_outlined,
                      size: 48,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.mySubmissionsEmptyTitle,
                      style: AppTextStyles.headlineMd(color: AppColors.onSurface),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.mySubmissionsEmptySubtitle,
                      style: AppTextStyles.bodyMd(
                        color: AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ResponsiveContent(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _MySubmissionCard(submission: items[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _MySubmissionCard extends StatelessWidget {
  const _MySubmissionCard({required this.submission});

  final SongSubmission submission;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final song = submission.payload;
    final isUpdate = submission.type == SubmissionType.update;
    final typeLabel =
        isUpdate ? l10n.moderationTypeUpdate : l10n.moderationTypeCreate;
    final statusLabel = _statusLabel(l10n, submission.status);
    final statusColors = _statusColors(submission.status);
    final createdAt = submission.createdAt;

    return Material(
      color: AppColors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isUpdate
                        ? AppColors.secondaryContainer
                        : AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    typeLabel,
                    style: AppTextStyles.labelSm(
                      color: isUpdate
                          ? AppColors.onSecondaryContainer
                          : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: AppTextStyles.labelSm(color: statusColors.foreground),
                  ),
                ),
                const Spacer(),
                if (song.number.isNotEmpty)
                  Text(
                    'N° ${song.number}',
                    style: AppTextStyles.labelSm(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              song.title,
              style: AppTextStyles.headlineMd(color: AppColors.onSurface),
            ),
            if (song.firstLine.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                song.firstLine,
                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (createdAt != null) ...[
              const SizedBox(height: 12),
              Text(
                DateFormat.yMMMd(l10n.localeName).add_Hm().format(createdAt.toLocal()),
                style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, SubmissionStatus status) {
    switch (status) {
      case SubmissionStatus.pending:
        return l10n.submissionStatusPending;
      case SubmissionStatus.approved:
        return l10n.submissionStatusApproved;
      case SubmissionStatus.rejected:
        return l10n.submissionStatusRejected;
    }
  }

  ({Color background, Color foreground}) _statusColors(SubmissionStatus status) {
    switch (status) {
      case SubmissionStatus.pending:
        return (
          background: AppColors.secondaryContainer.withValues(alpha: 0.5),
          foreground: AppColors.onSecondaryContainer,
        );
      case SubmissionStatus.approved:
        return (
          background: AppColors.primary.withValues(alpha: 0.12),
          foreground: AppColors.primary,
        );
      case SubmissionStatus.rejected:
        return (
          background: AppColors.error.withValues(alpha: 0.12),
          foreground: AppColors.error,
        );
    }
  }
}
