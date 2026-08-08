import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../songs/domain/entities/song.dart';
import '../widgets/lyric_section_editor.dart';
import '../widgets/success_modal.dart';

class AddSongScreen extends ConsumerStatefulWidget {
  const AddSongScreen({super.key});

  @override
  ConsumerState<AddSongScreen> createState() => _AddSongScreenState();
}

class _SectionItemData {
  _SectionItemData({required this.type, required this.title, String initialText = ''})
      : controller = TextEditingController(text: initialText);

  final SectionType type;
  final String title;
  final TextEditingController controller;
}

class _AddSongScreenState extends ConsumerState<AddSongScreen> {
  final _titleController = TextEditingController();
  final _numberController = TextEditingController();
  final _authorController = TextEditingController();

  final List<_SectionItemData> _sections = [];
  int _coupletCount = 0;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _addRefrain();
    _addCouplet();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _numberController.dispose();
    _authorController.dispose();
    for (final item in _sections) {
      item.controller.dispose();
    }
    super.dispose();
  }

  void _addCouplet() {
    setState(() {
      _coupletCount++;
      _sections.add(_SectionItemData(
        type: SectionType.couplet,
        title: 'Couplet $_coupletCount',
      ));
    });
  }

  void _addRefrain() {
    setState(() {
      _sections.add(_SectionItemData(
        type: SectionType.refrain,
        title: 'Refrain',
      ));
    });
  }

  void _removeSection(int index) {
    setState(() {
      _sections[index].controller.dispose();
      _sections.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    showDialog(
      context: context,
      builder: (context) => SuccessModal(
        onConfirm: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.primary),
          onPressed: () {},
        ),
        title: Text(
          'Sanctuary',
          style: AppTextStyles.headlineLgMobile(color: AppColors.primary),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Éditeur de Cantique',
              style: AppTextStyles.headlineMd(color: AppColors.onSurface),
            ),
            const SizedBox(height: 4),
            Text(
              'Créez ou modifiez les paroles et métadonnées du chant.',
              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),

            // Form Fields - Bento grid style
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _FormFieldContainer(
                    label: 'TITRE',
                    child: TextField(
                      controller: _titleController,
                      style: AppTextStyles.bodyLg(color: AppColors.onSurface),
                      decoration: const InputDecoration(
                        hintText: 'ex: Grand Dieu, nous te bénissons',
                        filled: false,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: _FormFieldContainer(
                    label: 'NUMÉRO',
                    child: TextField(
                      controller: _numberController,
                      style: AppTextStyles.bodyLg(color: AppColors.onSurface),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        hintText: 'ex: 124',
                        filled: false,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _FormFieldContainer(
              label: 'AUTEUR',
              child: TextField(
                controller: _authorController,
                style: AppTextStyles.bodyMd(color: AppColors.onSurface),
                decoration: const InputDecoration(
                  hintText: 'Auteur original ou compositeur',
                  filled: false,
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sections Editor List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _sections.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _sections[index];
                return LyricSectionEditor(
                  type: item.type,
                  title: item.title,
                  controller: item.controller,
                  onDelete: () => _removeSection(index),
                );
              },
            ),
            const SizedBox(height: 16),

            // Dynamic Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.outline),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _addCouplet,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Ajouter un couplet'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondary,
                      side: const BorderSide(color: AppColors.outline),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _addRefrain,
                    icon: const Icon(Icons.repeat, size: 18),
                    label: const Text('Ajouter un refrain'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _isSubmitting ? null : _submitForm,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload),
                label: Text(
                  _isSubmitting ? 'Publication en cours...' : 'Publier vers Firebase',
                  style: AppTextStyles.headlineMd(color: AppColors.onPrimary).copyWith(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Note: Les modifications seront immédiatement visibles pour tous les utilisateurs.',
                style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
          ],
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
