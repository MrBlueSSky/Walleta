import 'package:flutter/material.dart';

class SavingGoal {
  final String title;
  final double saved;
  final double goal;
  final IconData icon;
  final Color color;
  final DateTime targetDate;

  SavingGoal({
    required this.title,
    required this.saved,
    required this.goal,
    required this.icon,
    required this.color,
    required this.targetDate,
  });
}
