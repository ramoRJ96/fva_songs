import 'package:firebase_analytics/firebase_analytics.dart';

import 'analytics_client.dart';

/// Envoie les événements vers Firebase Analytics (GA4).
class FirebaseAnalyticsClient implements AnalyticsClient {
  FirebaseAnalyticsClient(this._analytics);

  final FirebaseAnalytics _analytics;

  @override
  Future<void> logScreenView({required String screenName}) {
    return _analytics.logScreenView(screenName: screenName);
  }

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) {
    return _analytics.logEvent(name: name, parameters: parameters);
  }
}
