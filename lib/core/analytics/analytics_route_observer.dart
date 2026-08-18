import 'package:flutter/material.dart';

import 'analytics_client.dart';

/// Enregistre un [screen_view] à chaque navigation GoRouter.
class AnalyticsRouteObserver extends NavigatorObserver {
  AnalyticsRouteObserver(this._analytics);

  final AnalyticsClient _analytics;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _trackRoute(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) {
      _trackRoute(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _trackRoute(newRoute);
    }
  }

  void _trackRoute(Route<dynamic> route) {
    final name = route.settings.name;
    if (name == null || name.isEmpty) return;

    _analytics.logScreenView(screenName: name);
  }
}
