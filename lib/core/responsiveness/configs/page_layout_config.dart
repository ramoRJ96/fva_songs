/// Config de mise en page partagée (padding, largeur max, colonnes).
class PageLayoutConfig {
  const PageLayoutConfig({
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.maxContentWidth,
    required this.gridCrossAxisCount,
    required this.gridChildAspectRatio,
    required this.useNavigationRail,
    required this.formColumns,
  });

  final double horizontalPadding;
  final double verticalPadding;

  /// Centre le contenu sur grands écrans (évite l'étirement).
  final double maxContentWidth;

  /// Colonnes pour les listes de chants / favoris.
  final int gridCrossAxisCount;
  final double gridChildAspectRatio;

  /// Rail latéral au lieu de la bottom bar (tablette+).
  final bool useNavigationRail;

  /// 1 = champs empilés, 2 = titre/numéro côte à côte, etc.
  final int formColumns;
}
