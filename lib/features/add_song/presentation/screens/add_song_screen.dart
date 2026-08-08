import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/responsiveness/extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../songs/domain/entities/song.dart';
import '../../../songs/presentation/providers/songs_providers.dart';
import '../widgets/lyric_section_editor.dart';
import '../widgets/success_modal.dart';

class AddSongScreen extends ConsumerStatefulWidget {
  const AddSongScreen({super.key});

  @override
  ConsumerState<AddSongScreen> createState() => _AddSongScreenState();
}

class _SectionItemData {
  _SectionItemData({
    required this.type,
    required this.title,
    this.index,
    String initialText = '',
  }) : controller = TextEditingController(text: initialText);

  final SectionType type;
  final String title;
  final int? index;
  final TextEditingController controller;
}

class _AddSongScreenState extends ConsumerState<AddSongScreen> {
  final _titleController = TextEditingController();
  final _numberController = TextEditingController();
  final _authorController = TextEditingController();
  final _themeController = TextEditingController();
  final _keyController = TextEditingController();

  SongLanguage _language = SongLanguage.fr;
  final List<_SectionItemData> _sections = [];
  int _coupletCount = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Sections de départ : 1 couplet + 1 refrain.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addCouplet();
      _addRefrain();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _numberController.dispose();
    _authorController.dispose();
    _themeController.dispose();
    _keyController.dispose();
    for (final item in _sections) {
      item.controller.dispose();
    }
    super.dispose();
  }

  void _addCouplet() {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _coupletCount++;
      _sections.add(
        _SectionItemData(
          type: SectionType.couplet,
          index: _coupletCount,
          title: l10n.coupletLabel(_coupletCount),
        ),
      );
    });
  }

  void _addRefrain() {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _sections.add(
        _SectionItemData(
          type: SectionType.refrain,
          title: l10n.refrainLabel,
        ),
      );
    });
  }

  void _addChorus() {
    // Un seul chorus recommandé.
    if (_sections.any((s) => s.type == SectionType.chorus)) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _sections.add(
        _SectionItemData(
          type: SectionType.chorus,
          title: l10n.chorusLabel,
        ),
      );
    });
  }

  void _removeSection(int index) {
    final l10n = AppLocalizations.of(context);
    setState(() {
      final removed = _sections.removeAt(index);
      removed.controller.dispose();

      // Recalcule uniquement les labels/index des couplets restants.
      _coupletCount = 0;
      for (final item in _sections) {
        if (item.type == SectionType.couplet) {
          _coupletCount++;
          // Mutation contrôlée des champs finals via remplacement local.
        }
      }
      var couplet = 0;
      for (var i = 0; i < _sections.length; i++) {
        final item = _sections[i];
        if (item.type != SectionType.couplet) continue;
        couplet++;
        if (item.index == couplet && item.title == l10n.coupletLabel(couplet)) {
          continue;
        }
        final text = item.controller.text;
        item.controller.dispose();
        _sections[i] = _SectionItemData(
          type: SectionType.couplet,
          index: couplet,
          title: l10n.coupletLabel(couplet),
          initialText: text,
        );
      }
      _coupletCount = couplet;
    });
  }

  List<LyricSection> _buildSections() {
    final result = <LyricSection>[];
    for (final item in _sections) {
      final lines = item.controller.text
          .split('\n')
          .map((l) => l.trimRight())
          .where((l) => l.trim().isNotEmpty)
          .toList();
      if (lines.isEmpty) continue;
      result.add(
        LyricSection(
          type: item.type,
          index: item.type == SectionType.couplet ? item.index : null,
          lines: lines,
        ),
      );
    }
    return result;
  }

  Future<void> _submitForm() async {
    final l10n = AppLocalizations.of(context);
    final title = _titleController.text.trim();
    final sections = _buildSections();

    if (title.isEmpty) {
      _showError(l10n.validationTitleRequired);
      return;
    }
    if (sections.isEmpty) {
      _showError(l10n.validationSectionRequired);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(addSongControllerProvider).add(
            title: title,
            number: _numberController.text,
            author: _authorController.text,
            theme: _themeController.text,
            key: _keyController.text,
            language: _language,
            sections: sections,
          );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      await showDialog<void>(
        context: context,
        builder: (context) => SuccessModal(
          onConfirm: () {
            Navigator.of(context).pop();
            context.go('/');
          },
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _hintFor(_SectionItemData item, AppLocalizations l10n) {
    switch (item.type) {
      case SectionType.refrain:
        return l10n.hintRefrain;
      case SectionType.chorus:
        return l10n.hintChorus;
      case SectionType.couplet:
        return l10n.hintCouplet;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final config = context.pageConfig;
    final hasChorus = _sections.any((s) => s.type == SectionType.chorus);
    final useTwoColumns = config.formColumns >= 2;

    final titleField = _FormFieldContainer(
      label: l10n.fieldTitle,
      child: TextField(
        controller: _titleController,
        style: AppTextStyles.bodyLg(color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: l10n.hintTitle,
          filled: false,
          border: InputBorder.none,
        ),
      ),
    );
    final numberField = _FormFieldContainer(
      label: l10n.fieldNumber,
      child: TextField(
        controller: _numberController,
        style: AppTextStyles.bodyLg(color: AppColors.onSurface),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: l10n.hintNumber,
          filled: false,
          border: InputBorder.none,
        ),
      ),
    );
    final themeField = _FormFieldContainer(
      label: l10n.fieldTheme,
      child: TextField(
        controller: _themeController,
        style: AppTextStyles.bodyMd(color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: l10n.hintTheme,
          filled: false,
          border: InputBorder.none,
        ),
      ),
    );
    final keyField = _FormFieldContainer(
      label: l10n.fieldKey,
      child: TextField(
        controller: _keyController,
        style: AppTextStyles.bodyMd(color: AppColors.onSurface),
        decoration: InputDecoration(
          hintText: l10n.hintKey,
          filled: false,
          border: InputBorder.none,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          l10n.appTitle,
          style: AppTextStyles.headlineLgMobile(color: AppColors.primary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: config.horizontalPadding,
          vertical: config.verticalPadding,
        ),
        child: ResponsiveContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.editorTitle,
                style: AppTextStyles.headlineMd(color: AppColors.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.editorSubtitle,
                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              if (useTwoColumns)
                Row(
                  children: [
                    Expanded(flex: 2, child: titleField),
                    const SizedBox(width: 12),
                    Expanded(child: numberField),
                  ],
                )
              else ...[
                titleField,
                const SizedBox(height: 12),
                numberField,
              ],
              const SizedBox(height: 12),
              _FormFieldContainer(
                label: l10n.fieldAuthor,
                child: TextField(
                  controller: _authorController,
                  style: AppTextStyles.bodyMd(color: AppColors.onSurface),
                  decoration: InputDecoration(
                    hintText: l10n.hintAuthor,
                    filled: false,
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (useTwoColumns)
                Row(
                  children: [
                    Expanded(child: themeField),
                    const SizedBox(width: 12),
                    Expanded(child: keyField),
                  ],
                )
              else ...[
                themeField,
                const SizedBox(height: 12),
                keyField,
              ],
              const SizedBox(height: 12),
              _FormFieldContainer(
                label: l10n.fieldLanguage,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<SongLanguage>(
                    value: _language,
                    isExpanded: true,
                    items: [
                      DropdownMenuItem(
                        value: SongLanguage.fr,
                        child: Text(l10n.languageFrench),
                      ),
                      DropdownMenuItem(
                        value: SongLanguage.mg,
                        child: Text(l10n.languageMalagasy),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _language = value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _sections.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = _sections[index];
                  return LyricSectionEditor(
                    type: item.type,
                    title: item.title,
                    controller: item.controller,
                    hintText: _hintFor(item, l10n),
                    onDelete: () => _removeSection(index),
                  );
                },
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _addCouplet,
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(l10n.addCouplet),
                  ),
                  OutlinedButton.icon(
                    onPressed: _addRefrain,
                    icon: const Icon(Icons.repeat, size: 18),
                    label: Text(l10n.addRefrain),
                  ),
                  OutlinedButton.icon(
                    onPressed: hasChorus ? null : _addChorus,
                    icon: const Icon(Icons.music_note, size: 18),
                    label: Text(l10n.addChorus),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isSubmitting ? null : _submitForm,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _isSubmitting ? l10n.publishing : l10n.publish,
                    style: AppTextStyles.headlineMd(color: AppColors.onPrimary)
                        .copyWith(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  l10n.publishNote,
                  style:
                      AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormFieldContainer extends StatelessWidget {
  const _FormFieldContainer({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelCaps(color: AppColors.primary),
          ),
          child,
        ],
      ),
    );
  }
}
