import 'package:flutter/material.dart';

import 'configs/page_layout_config.dart';
import 'extensions.dart';

/// Centralise les configs UI selon la largeur d'écran (pattern UIConfigurations).
class UiConfigurations {
  UiConfigurations(BuildContext context) {
    if (context.isSmall) {
      _small();
    } else if (context.isMedium) {
      _medium();
    } else if (context.isLarge) {
      _large();
    } else if (context.isXLarge) {
      _extraLarge();
    } else {
      _xxLarge();
    }
  }

  late final PageLayoutConfig page;

  void _small() {
    page = const PageLayoutConfig(
      horizontalPadding: 20,
      verticalPadding: 16,
      maxContentWidth: double.infinity,
      gridCrossAxisCount: 1,
      gridChildAspectRatio: 2.6,
      useNavigationRail: false,
      formColumns: 1,
    );
  }

  void _medium() {
    page = const PageLayoutConfig(
      horizontalPadding: 24,
      verticalPadding: 20,
      maxContentWidth: 720,
      gridCrossAxisCount: 2,
      gridChildAspectRatio: 2.2,
      useNavigationRail: false,
      formColumns: 2,
    );
  }

  void _large() {
    page = const PageLayoutConfig(
      horizontalPadding: 32,
      verticalPadding: 24,
      maxContentWidth: 960,
      gridCrossAxisCount: 2,
      gridChildAspectRatio: 2.4,
      useNavigationRail: true,
      formColumns: 2,
    );
  }

  void _extraLarge() {
    page = const PageLayoutConfig(
      horizontalPadding: 40,
      verticalPadding: 28,
      maxContentWidth: 1100,
      gridCrossAxisCount: 3,
      gridChildAspectRatio: 2.1,
      useNavigationRail: true,
      formColumns: 2,
    );
  }

  void _xxLarge() {
    page = const PageLayoutConfig(
      horizontalPadding: 48,
      verticalPadding: 32,
      maxContentWidth: 1280,
      gridCrossAxisCount: 3,
      gridChildAspectRatio: 2.0,
      useNavigationRail: true,
      formColumns: 2,
    );
  }
}
