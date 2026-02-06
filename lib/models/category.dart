// Clase auxiliar para mantener compatibilidad
import 'dart:ui';

import 'package:flutter/material.dart';

class CategoryData {
  final String name;
  final double amount;
  final Color color;
  final IconData icon;
  final String category;

  CategoryData(this.name, this.amount, this.color, this.icon, this.category);
}

// // Clase auxiliar para mantener compatibilidad
// import 'dart:ui';

// import 'package:flutter/material.dart';

// class CategoryData {
//   final String name;
//   final double amount;
//   final Color color;
//   final IconData icon;

//   CategoryData(
//     this.name,
//     this.amount,
//     this.color,
//     this.icon, {
//     required String category,
//   });
// }
