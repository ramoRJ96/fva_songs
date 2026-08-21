import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/responsiveness/extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _authorPhotoAsset = 'assets/branding/app_icon.png';

  Future<void> _openMail(String email) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': 'FVA Songs'},
    );
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final config = context.pageConfig;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          l10n.aboutTitle,
          style: AppTextStyles.headlineMd(color: AppColors.primary),
        ),
        centerTitle: true,
      ),
      body: ResponsiveContent(
        padding: EdgeInsets.fromLTRB(
          config.horizontalPadding,
          config.verticalPadding,
          config.horizontalPadding,
          24,
        ),
        child: ListView(
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  _authorPhotoAsset,
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.aboutAuthorName,
              style: AppTextStyles.headlineMd(color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.aboutAuthorRole,
              style: AppTextStyles.labelSm(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.aboutBody,
              style: AppTextStyles.bodyMd(),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.aboutDonateTitle,
              style: AppTextStyles.labelCaps(),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.aboutDonateBody,
              style: AppTextStyles.bodyMd(),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _openMail(l10n.aboutContactEmail),
                icon: const Icon(Icons.mail_outline),
                label: Text(l10n.aboutContactEmail),
              ),
            ),
            const SizedBox(height: 32),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final info = snapshot.data;
                if (info == null) return const SizedBox.shrink();
                return Text(
                  l10n.aboutVersion('${info.version}+${info.buildNumber}'),
                  style: AppTextStyles.labelSm(),
                  textAlign: TextAlign.center,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
