import 'package:flutter/material.dart';

/// Centralized elevation scale (Material 3). Use these instead of ad-hoc
/// `elevation:` values scattered across pages.
class AppElevation {
  AppElevation._();

  static const double level0 = 0;
  static const double level1 = 1;
  static const double level2 = 3;
  static const double level3 = 6;
  static const double scrolledUnder = 0.5;
}

/// Matching shadow set for custom painted surfaces.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(
      color: Color(0x0F0F172A),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> popover = <BoxShadow>[
    BoxShadow(
      color: Color(0x1F0F172A),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}
