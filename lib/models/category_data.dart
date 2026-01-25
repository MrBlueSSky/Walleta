import 'package:flutter/material.dart';

// Modelos de datos
class CategoryData {
  final String name;
  final double amount;
  final Color color;
  final IconData icon;

  CategoryData(this.name, this.amount, this.color, this.icon);
}

class SharedExpense {
  final String description;
  final double amount;
  final bool isOwed; // true = debes, false = te deben
  final String person;
  final IconData icon;

  SharedExpense(
    this.description,
    this.amount,
    this.isOwed,
    this.person,
    this.icon,
  );
}
