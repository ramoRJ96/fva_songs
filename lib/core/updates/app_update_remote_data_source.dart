import 'dart:convert';
import 'dart:io';

import 'app_release_info.dart';

/// Lit le manifeste de version hébergé sur Firebase Hosting.
class AppUpdateRemoteDataSource {
  AppUpdateRemoteDataSource({this.manifestUrl = _defaultManifestUrl});

  static const _defaultManifestUrl =
      'https://fvasongs-d8055.web.app/app-version.json';

  final String manifestUrl;

  Future<AppReleaseInfo?> fetchLatest() async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(manifestUrl));
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) return null;

      final body = await response.transform(utf8.decoder).join();
      final json = jsonDecode(body);
      if (json is! Map<String, dynamic>) return null;

      final info = AppReleaseInfo.fromJson(json);
      return info.isValid ? info : null;
    } on Object {
      return null;
    } finally {
      client.close();
    }
  }
}
