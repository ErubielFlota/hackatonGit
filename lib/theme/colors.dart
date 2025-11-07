import 'package:flutter/material.dart';

/// Colores base globales para tu app
const Color primaryColor = Color(0xFF0078D0); // Azul principal
const Color backgroundColor = Color(0xFFFBFCFB); // Fondo claro
const Color textColor = Color(0xFF1E1E1E); // Texto principal

/// Extensiones para obtener tonos derivados reales (más claro / más oscuro)
extension CustomColorShades on Color {
  Color get lighter {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness + 0.25).clamp(0.0, 1.0))
        .toColor();
  }

  Color get darker {
    final hsl = HSLColor.fromColor(this);
    return hsl
        .withLightness((hsl.lightness - 0.25).clamp(0.0, 1.0))
        .toColor();
  }
}
