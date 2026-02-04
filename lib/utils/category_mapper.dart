import 'package:flutter/material.dart';

class CategoryMapper {
  // Mapa de categorías a iconos
  static final Map<String, IconData> categoryIcons = {
    'compras': Icons.shopping_bag,
    'comida': Icons.restaurant,
    'restaurante': Icons.restaurant,
    'entretenimiento': Icons.sports_esports,
    'hogar': Icons.home,
    'transporte': Icons.directions_car,
    'servicios': Icons.receipt_long,
    'salud': Icons.local_hospital,
    'educación': Icons.school,
    'ropa': Icons.checkroom,
    'deportes': Icons.sports,
    'viajes': Icons.flight,
    'regalos': Icons.card_giftcard,
    'mascotas': Icons.pets,
    'ingreso': Icons.attach_money,
    'negocios': Icons.business,
    'inversiones': Icons.trending_up,
    'ahorro': Icons.savings,
    'seguros': Icons.security,
    'impuestos': Icons.receipt,
    'cuotas': Icons.payment,
    'deuda': Icons.money_off,
    'otros': Icons.category,
  };

  // Mapa de categorías a colores
  static final Map<String, Color> categoryColors = {
    'compras': const Color(0xFF2563EB),
    'comida': const Color(0xFF10B981),
    'restaurante': const Color(0xFF10B981),
    'entretenimiento': const Color(0xFF7C3AED),
    'hogar': const Color(0xFFDB2777),
    'transporte': const Color(0xFF0EA5E9),
    'servicios': const Color(0xFF0891B2),
    'salud': const Color(0xFFDC2626),
    'educación': const Color(0xFF4F46E5),
    'ropa': const Color(0xFFC026D3),
    'deportes': const Color(0xFF059669),
    'viajes': const Color(0xFFEA580C),
    'regalos': const Color(0xFFBE185D),
    'mascotas': const Color(0xFF65A30D),
    'ingreso': const Color(0xFF10B981),
    'negocios': const Color(0xFF7C3AED),
    'inversiones': const Color(0xFF7DD3FC),
    'ahorro': const Color(0xFF0D9488),
    'seguros': const Color(0xFF475569),
    'impuestos': const Color(0xFF991B1B),
    'cuotas': const Color(0xFF9333EA),
    'deuda': const Color(0xFFDC2626),
    'otros': const Color(0xFF64748B),
  };

  // Método para obtener icono por categoría
  static IconData getIconForCategory(String category) {
    final normalizedCategory = category.toLowerCase().trim();
    return categoryIcons[normalizedCategory] ?? Icons.category;
  }

  // Método para obtener color por categoría
  static Color getColorForCategory(String category) {
    final normalizedCategory = category.toLowerCase().trim();
    return categoryColors[normalizedCategory] ?? const Color(0xFF6B7280);
  }

  // Método para normalizar categoría (opcional)
  static String normalizeCategory(String rawCategory) {
    final category = rawCategory.toLowerCase().trim();

    // Mapeo de variaciones
    final variations = {
      'comidas': 'comida',
      'alimentos': 'comida',
      'supermercado': 'compras',
      'tienda': 'compras',
      'transportes': 'transporte',
      'vehículo': 'transporte',
      'casa': 'hogar',
      'vivienda': 'hogar',
      'servicio': 'servicios',
      'pago de servicios': 'servicios',
      'médico': 'salud',
      'estudio': 'educación',
      'vestimenta': 'ropa',
      'deporte': 'deportes',
      'ejercicio': 'deportes',
      'viaje': 'viajes',
      'vacaciones': 'viajes',
      'regalo': 'regalos',
      'obsequio': 'regalos',
      'mascota': 'mascotas',
      'animales': 'mascotas',
      'ingresos': 'ingreso',
      'sueldo': 'ingreso',
      'negocio': 'negocios',
      'trabajo': 'negocios',
      'inversión': 'inversiones',
      'ahorros': 'ahorro',
      'seguro': 'seguros',
      'impuesto': 'impuestos',
      'tributo': 'impuestos',
      'cuota': 'cuotas',
      'mensualidad': 'cuotas',
      'préstamo': 'deuda',
      'otro': 'otros',
      'general': 'otros',
      'varios': 'otros',
    };

    return variations[category] ?? category;
  }
}
