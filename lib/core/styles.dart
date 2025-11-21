import 'package:flutter/material.dart';
import 'colors.dart';

class HannamiTextStyles {
  const HannamiTextStyles._();

  static const TextStyle titleMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: HannamiColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: HannamiColors.textSecondary,
    height: 1.4,
  );
}

class HannamiSpacing {
  const HannamiSpacing._();
  static const double cardRadius = 18;
  static const double padding = 16;
  static const EdgeInsets cardPadding = EdgeInsets.all(padding);
}
