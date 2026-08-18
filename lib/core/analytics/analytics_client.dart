/// Contrat d'analytique applicative (sans dépendance Firebase).
abstract class AnalyticsClient {
  Future<void> logScreenView({
    required String screenName,
  });

  Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  });
}

/// Implémentation neutre pour les tests et les builds sans collecte.
class NoOpAnalyticsClient implements AnalyticsClient {
  const NoOpAnalyticsClient();

  @override
  Future<void> logScreenView({required String screenName}) async {}

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {}
}
