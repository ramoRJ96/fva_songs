import 'package:flutter/material.dart';

import 'breakpoints.dart';
import 'configs/page_layout_config.dart';
import 'ui_configurations.dart';

extension ResponsiveContext on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;

  bool get isSmall => screenWidth <= Breakpoints.sm;
  bool get isMedium => !isSmall && screenWidth <= Breakpoints.md;
  bool get isLarge => !isMedium && screenWidth <= Breakpoints.lg;
  bool get isXLarge => !isLarge && screenWidth <= Breakpoints.xl;
  bool get isXXLarge => screenWidth > Breakpoints.xl;

  bool get fromLarge => isLarge || isXLarge || isXXLarge;

  UiConfigurations get uiConfig => UiConfigurations(this);
  PageLayoutConfig get pageConfig => uiConfig.page;
}

/// Centre un enfant dans une largeur max (tablette / desktop).
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final config = context.pageConfig;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: config.maxContentWidth),
        child: padding == null
            ? child
            : Padding(padding: padding!, child: child),
      ),
    );
  }
}
