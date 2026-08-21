import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../songs/domain/entities/song.dart';
import '../../../songs/domain/entities/song_submission.dart';
import '../../../songs/domain/services/song_diff.dart';
import '../../../songs/presentation/providers/songs_providers.dart';

class SubmissionDiffSheet extends ConsumerWidget {
  const SubmissionDiffSheet({
    super.key,
    required this.submission,
    this.controller,
  });

  final SongSubmission submission;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final proposed = submission.payload;
    final isUpdate = submission.type == SubmissionType.update;
    final targetId = submission.targetSongId;

    if (!isUpdate || targetId == null || targetId.isEmpty) {
      return _ProposedOnly(
        song: proposed,
        l10n: l10n,
        controller: controller,
      );
    }

    final currentAsync = ref.watch(songDetailProvider(targetId));
    return currentAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(48),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => _ProposedOnly(
        song: proposed,
        l10n: l10n,
        missingCurrent: true,
        controller: controller,
      ),
      data: (current) {
        if (current == null) {
          return _ProposedOnly(
            song: proposed,
            l10n: l10n,
            missingCurrent: true,
            controller: controller,
          );
        }
        final diff = SongDiff.compare(current: current, proposed: proposed);
        return _UpdateDiff(
          current: current,
          proposed: proposed,
          diff: diff,
          l10n: l10n,
          controller: controller,
        );
      },
    );
  }
}

class _ProposedOnly extends StatelessWidget {
  const _ProposedOnly({
    required this.song,
    required this.l10n,
    this.missingCurrent = false,
    this.controller,
  });

  final Song song;
  final AppLocalizations l10n;
  final bool missingCurrent;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(24),
      children: [
        if (missingCurrent) ...[
          Text(
            l10n.moderationCurrentMissing,
            style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
        ],
        _SongPreview(song: song, l10n: l10n),
      ],
    );
  }
}

class _UpdateDiff extends StatelessWidget {
  const _UpdateDiff({
    required this.current,
    required this.proposed,
    required this.diff,
    required this.l10n,
    this.controller,
  });

  final Song current;
  final Song proposed;
  final SongDiff diff;
  final AppLocalizations l10n;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          proposed.title.isEmpty ? '—' : proposed.title,
          style: AppTextStyles.headlineMd(color: AppColors.onSurface),
        ),
        const SizedBox(height: 16),
        for (final field in diff.fields) ...[
          _FieldDiffRow(field: field, l10n: l10n),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 8),
        Text(
          l10n.moderationDiffLyrics,
          style: AppTextStyles.labelCaps(color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        if (!diff.lyricsChanged)
          Text(
            l10n.moderationUnchanged,
            style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
          )
        else ...[
          _LyricsColumn(
            label: l10n.moderationDiffCurrent,
            song: current,
            l10n: l10n,
            muted: true,
          ),
          const SizedBox(height: 16),
          _LyricsColumn(
            label: l10n.moderationDiffProposed,
            song: proposed,
            l10n: l10n,
            muted: false,
          ),
        ],
      ],
    );
  }
}

class _FieldDiffRow extends StatelessWidget {
  const _FieldDiffRow({required this.field, required this.l10n});

  final SongFieldDiff field;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final label = _labelFor(field.key, l10n);
    if (!field.changed) {
      final value = field.proposed.isEmpty ? '—' : field.proposed;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelCaps(color: AppColors.primary)),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyMd(color: AppColors.onSurface),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelCaps(color: AppColors.primary)),
        const SizedBox(height: 4),
        Text(
          field.current.isEmpty ? '—' : field.current,
          style: AppTextStyles.bodyMd(
            color: AppColors.onSurfaceVariant,
          ).copyWith(decoration: TextDecoration.lineThrough),
        ),
        Text(
          field.proposed.isEmpty ? '—' : field.proposed,
          style: AppTextStyles.bodyMd(color: AppColors.onSurface).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _labelFor(String key, AppLocalizations l10n) {
    switch (key) {
      case 'title':
        return l10n.fieldTitle;
      case 'number':
        return l10n.fieldNumber;
      case 'author':
        return l10n.fieldAuthor;
      case 'theme':
        return l10n.fieldTheme;
      case 'key':
        return l10n.fieldKey;
      case 'language':
        return l10n.fieldLanguage;
      default:
        return key;
    }
  }
}

class _LyricsColumn extends StatelessWidget {
  const _LyricsColumn({
    required this.label,
    required this.song,
    required this.l10n,
    required this.muted,
  });

  final String label;
  final Song song;
  final AppLocalizations l10n;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final color = muted ? AppColors.onSurfaceVariant : AppColors.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        for (final section in song.sectionsForDisplay) ...[
          Text(
            _sectionTitle(section, l10n),
            style: AppTextStyles.labelCaps(color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          Text(
            section.lines.join('\n'),
            style: AppTextStyles.bodyLg(color: color),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  String _sectionTitle(LyricSection section, AppLocalizations l10n) {
    switch (section.type) {
      case SectionType.refrain:
        return l10n.refrainLabel;
      case SectionType.chorus:
        return l10n.chorusLabel;
      case SectionType.couplet:
        return l10n.coupletLabel(section.index ?? 0);
    }
  }
}

class _SongPreview extends StatelessWidget {
  const _SongPreview({required this.song, required this.l10n});

  final Song song;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          song.title.isEmpty ? '—' : song.title,
          style: AppTextStyles.headlineMd(color: AppColors.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          [
            if (song.number.isNotEmpty) 'N° ${song.number}',
            if (song.author.isNotEmpty) song.author,
            if (song.key.isNotEmpty) song.key,
            song.language.code.toUpperCase(),
          ].join(' · '),
          style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        for (final section in song.sectionsForDisplay) ...[
          Text(
            _sectionTitle(section, l10n),
            style: AppTextStyles.labelCaps(color: AppColors.primary),
          ),
          const SizedBox(height: 6),
          Text(
            section.lines.join('\n'),
            style: AppTextStyles.bodyLg(color: AppColors.onSurface),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  String _sectionTitle(LyricSection section, AppLocalizations l10n) {
    switch (section.type) {
      case SectionType.refrain:
        return l10n.refrainLabel;
      case SectionType.chorus:
        return l10n.chorusLabel;
      case SectionType.couplet:
        return l10n.coupletLabel(section.index ?? 0);
    }
  }
}
