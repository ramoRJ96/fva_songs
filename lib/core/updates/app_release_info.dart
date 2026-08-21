/// Manifeste de version publié sur Firebase Hosting (`/app-version.json`).
class AppReleaseInfo {
  const AppReleaseInfo({
    required this.versionName,
    required this.versionCode,
    required this.downloadUrl,
  });

  final String versionName;
  final int versionCode;
  final String downloadUrl;

  factory AppReleaseInfo.fromJson(Map<String, dynamic> json) {
    return AppReleaseInfo(
      versionName: json['versionName'] as String? ?? '',
      versionCode: (json['versionCode'] as num?)?.toInt() ?? 0,
      downloadUrl: json['downloadUrl'] as String? ?? '',
    );
  }

  bool get isValid =>
      versionName.isNotEmpty && versionCode > 0 && downloadUrl.isNotEmpty;
}

/// Compare la version distante à la version installée (Android `versionCode`).
class AppUpdateChecker {
  const AppUpdateChecker();

  AppReleaseInfo? findUpdate({
    required AppReleaseInfo remote,
    required int localVersionCode,
  }) {
    if (!remote.isValid) return null;
    if (remote.versionCode > localVersionCode) return remote;
    return null;
  }
}
