import 'package:flutter/material.dart';

extension TextstyleExtension on TextStyle {
  /// fontweight: 100
  TextStyle get thin => copyWith(fontWeight: FontWeight.w100);

  /// fontweight: 200
  TextStyle get extraLight => copyWith(fontWeight: FontWeight.w200);

  /// fontweight: 300
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);

  /// fontweight: 400
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);

  /// fontweight: 500
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);

  /// fontweight: 600
  TextStyle get semi => copyWith(fontWeight: FontWeight.w600);

  /// fontweight: 700
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);

  /// fontweight: 800
  TextStyle get extraBold => copyWith(fontWeight: FontWeight.w800);

  /// underlined text
  TextStyle get underlined => copyWith(decoration: TextDecoration.underline);

  /// apply color
  TextStyle applyColor(Color color) => copyWith(color: color);
}
