import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'analytics_client.dart';
import 'firebase_analytics_client.dart';

final analyticsClientProvider = Provider<AnalyticsClient>((ref) {
  return FirebaseAnalyticsClient(FirebaseAnalytics.instance);
});
