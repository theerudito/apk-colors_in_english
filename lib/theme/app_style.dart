import 'package:flutter/material.dart';

class AppStyle {
  static const Color background = Color(0xFF0B0B28);
  static const Color panel = Color(0xFF16164A);
  static const Color panelBorder = Color(0xFF3A3A7A);

  static TextStyle pixel({
    double size = 10,
    Color color = Colors.white,
    double height = 1.5,
  }) {
    return TextStyle(
      fontFamily: 'PressStart2P',
      fontSize: size,
      color: color,
      height: height,
    );
  }
}
