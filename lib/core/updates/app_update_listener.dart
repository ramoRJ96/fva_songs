import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import 'app_update_service.dart';

/// Vérifie au démarrage si une version plus récente est disponible sur Hosting.
class AppUpdateListener extends ConsumerStatefulWidget {
  const AppUpdateListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppUpdateListener> createState() => _AppUpdateListenerState();
}

class _AppUpdateListenerState extends ConsumerState<AppUpdateListener> {
  var _checked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
  }

  Future<void> _checkForUpdate() async {
    if (_checked || !mounted) return;
    _checked = true;

    final update = await ref.read(appUpdateServiceProvider).checkForUpdate();
    if (!mounted || update == null) return;

    await showDialog<void>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        return AlertDialog(
          title: Text(l10n.updateAvailableTitle),
          content: Text(
            l10n.updateAvailableMessage(update.versionName),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.updateLaterButton),
            ),
            FilledButton(
              onPressed: () async {
                final uri = Uri.parse(update.downloadUrl);
                await launchUrl(uri, mode: LaunchMode.externalApplication);
                if (context.mounted) Navigator.of(context).pop();
              },
              child: Text(l10n.updateDownloadButton),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
