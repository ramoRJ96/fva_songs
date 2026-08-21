import 'package:flutter_test/flutter_test.dart';
import 'package:fva_songs/core/updates/app_release_info.dart';

void main() {
  const checker = AppUpdateChecker();

  const remote = AppReleaseInfo(
    versionName: '0.1.3',
    versionCode: 4,
    downloadUrl: 'https://example.com/app.apk',
  );

  test('propose une mise à jour si versionCode distante > local', () {
    expect(
      checker.findUpdate(remote: remote, localVersionCode: 3),
      remote,
    );
  });

  test('ne propose rien si déjà à jour', () {
    expect(
      checker.findUpdate(remote: remote, localVersionCode: 4),
      isNull,
    );
  });

  test('ignore un manifeste invalide', () {
    const invalid = AppReleaseInfo(
      versionName: '',
      versionCode: 0,
      downloadUrl: '',
    );
    expect(
      checker.findUpdate(remote: invalid, localVersionCode: 1),
      isNull,
    );
  });
}
