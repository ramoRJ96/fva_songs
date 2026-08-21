import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'app_release_info.dart';
import 'app_update_remote_data_source.dart';

final appUpdateRemoteDataSourceProvider = Provider<AppUpdateRemoteDataSource>(
  (ref) => AppUpdateRemoteDataSource(),
);

final appUpdateCheckerProvider = Provider<AppUpdateChecker>(
  (ref) => const AppUpdateChecker(),
);

final appUpdateServiceProvider = Provider<AppUpdateService>((ref) {
  return AppUpdateService(
    remote: ref.watch(appUpdateRemoteDataSourceProvider),
    checker: ref.watch(appUpdateCheckerProvider),
  );
});

class AppUpdateService {
  AppUpdateService({
    required AppUpdateRemoteDataSource remote,
    required AppUpdateChecker checker,
  })  : _remote = remote,
        _checker = checker;

  final AppUpdateRemoteDataSource _remote;
  final AppUpdateChecker _checker;

  Future<AppReleaseInfo?> checkForUpdate() async {
    final remote = await _remote.fetchLatest();
    if (remote == null) return null;

    final packageInfo = await PackageInfo.fromPlatform();
    final localCode = int.tryParse(packageInfo.buildNumber) ?? 0;

    return _checker.findUpdate(
      remote: remote,
      localVersionCode: localCode,
    );
  }
}
