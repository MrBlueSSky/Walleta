// lib/utils/voice_text_parser.dart
class VoiceTextParser {
  // En _validateStructuredData, agrega esta lógica ANTES de validar el tipo:

  // Detección mejorada de gastos compartidos
  static bool detectSharedExpense(String text) {
    final lowerText = text.toLowerCase();

    // Palabras clave que indican gasto compartido
    final sharedKeywords = [
      'con amigos',
      'con unos amigos',
      'con amigo',
      'entre amigos',
      'con compañeros',
      'con unos',
      'con ellos',
      'con ella',
      'con él',
      'compartimos',
      'compartido',
      'compartida',
      'dividimos',
      'entre todos',
      'cada uno',
    ];

    // Verificar si contiene alguna palabra clave
    for (final keyword in sharedKeywords) {
      if (lowerText.contains(keyword)) {
        return true;
      }
    }

    // Verificar patrones específicos
    final patterns = [
      RegExp(r'con\s+unos?\s+\w+'), // "con unos amigos", "con un amigo"
      RegExp(r'entre\s+\d+\s+personas'), // "entre 3 personas"
      RegExp(r'con\s+\w+\s+y\s+\w+'), // "con Juan y María"
    ];

    for (final pattern in patterns) {
      if (pattern.hasMatch(lowerText)) {
        return true;
      }
    }

    return false;
  }

  // ==================== MÉTODOS DE VALIDACIÓN ====================
  static bool isCommonWord(String word) {
    const commonWords = {
      'el',
      'la',
      'los',
      'las',
      'un',
      'una',
      'unos',
      'unas',
      'de',
      'del',
      'al',
      'a',
      'en',
      'y',
      'o',
      'pero',
      'por',
      'para',
      'con',
      'sin',
      'sobre',
      'entre',
      'hacia',
      'desde',
      'mi',
      'tu',
      'su',
      'nuestro',
      'vuestro',
      'yo',
      'tú',
      'él',
      'ella',
      'nosotros',
      'vosotros',
      'ellos',
      'que',
      'cual',
      'quien',
      'cuyo',
      'cuanto',
      'donde',
      'cuando',
      'como',
      'porque',
      'aunque',
      'si',
      'sino',
      'mas',
    };
    return commonWords.contains(word.toLowerCase());
  }

  // ==================== EXTRACCIÓN DE FECHAS ====================
  static String? extractDateFromText(String text) {
    final lowerText = text.toLowerCase();

    // Meses
    final monthMap = {
      'enero': 1,
      'febrero': 2,
      'marzo': 3,
      'abril': 4,
      'mayo': 5,
      'junio': 6,
      'julio': 7,
      'agosto': 8,
      'septiembre': 9,
      'octubre': 10,
      'noviembre': 11,
      'diciembre': 12,
    };

    final now = DateTime.now();

    // Patrones de fecha
    final patterns = [
      // "15 de enero"
      RegExp(r'(\d{1,2})\s+de\s+(\w+)'),
      // "el 15/01"
      RegExp(r'(\d{1,2})[/-](\d{1,2})'),
      // "el próximo viernes"
      RegExp(r'(próximo|proximo|este|siguiente)\s+(\w+)'),
      // "mañana", "pasado mañana"
      RegExp(r'\b(mañana|pasado\s+mañana|hoy|ayer)\b'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(lowerText);
      if (match != null) {
        try {
          if (pattern == patterns[0]) {
            // "15 de enero"
            final day = int.parse(match.group(1)!);
            final monthStr = match.group(2)!;
            final month = monthMap[monthStr];
            if (month != null) {
              return '${now.year}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
            }
          } else if (pattern == patterns[3]) {
            // "mañana", "hoy", etc.
            final word = match.group(1)!;
            if (word == 'hoy') return now.toIso8601String().split('T')[0];
            if (word == 'mañana') {
              final tomorrow = now.add(const Duration(days: 1));
              return tomorrow.toIso8601String().split('T')[0];
            }
            if (word.contains('pasado')) {
              final dayAfter = now.add(const Duration(days: 2));
              return dayAfter.toIso8601String().split('T')[0];
            }
          }
        } catch (e) {
          continue;
        }
      }
    }

    return null;
  }

  // ==================== GENERACIÓN DE TÍTULOS ====================
  static String generateTitle(
    String type,
    double? amount,
    String category,
    String? person,
  ) {
    final amountStr =
        amount != null ? ' de \$${amount.toStringAsFixed(2)}' : '';
    final personStr = person != null ? ' a $person' : '';

    switch (type) {
      case 'personal_expense':
        return 'Gasto$amountStr en $category$personStr';
      case 'income':
        return 'Ingreso$amountStr$personStr';
      case 'shared_expenses':
        return 'Gasto compartido$amountStr';
      case 'payment_to_person':
        return 'Pago$amountStr$personStr';
      case 'loan_given':
        return 'Préstamo$amountStr a $person';
      case 'loan_received':
        return 'Préstamo$amountStr de $person';
      case 'money_request':
        return 'Cobro$amountStr a $person';
      case 'split_bill':
        return 'Cuenta dividida$amountStr';
      default:
        return 'Transacción$amountStr';
    }
  }

  // ==================== GENERACIÓN DE DESCRIPCIONES ====================
  static String generateDescription(
    String type,
    String originalText,
    double? amount,
    String? person,
  ) {
    final amountStr =
        amount != null ? ' por \$${amount.toStringAsFixed(2)}' : '';

    switch (type) {
      case 'personal_expense':
        return 'Gasto registrado$amountStr';
      case 'shared_expense':
        return 'Gasto compartido registrado$amountStr';
      case 'loan_given':
        return 'Préstamo otorgado$amountStr${person != null ? ' a $person' : ''}';
      case 'payment_to_person':
        return 'Pago realizado$amountStr${person != null ? ' a $person' : ''}';
      default:
        return originalText;
    }
  }

  // ==================== GENERACIÓN DE MENSAJES ====================
  static String generateUserMessage(
    String type,
    double? amount,
    String category,
    String? person,
    bool isShared,
  ) {
    final amountStr =
        amount != null ? ' de \$${amount.toStringAsFixed(2)}' : '';
    final personStr = person != null ? ' para $person' : '';
    final sharedStr = isShared ? ' compartido' : '';

    switch (type) {
      case 'personal_expense':
        return '✅ Gasto$sharedStr$amountStr en $category$personStr registrado';
      case 'income':
        return '💰 Ingreso$amountStr registrado';
      case 'shared_expenses':
        return '👥 Gasto compartido$amountStr registrado';
      case 'payment_to_person':
        return '💸 Pago$amountStr a $person registrado';
      case 'loan':
        return '📝 Préstamo$amountStr a $person registrado';
      case 'money_request':
        return '📨 Solicitud de pago$amountStr a $person creada';
      case 'split_bill':
        return '🍽️ Cuenta dividida$amountStr registrada';
      default:
        return '📋 Transacción registrada';
    }
  }

  // ==================== DETERMINACIÓN DE SUBTIPOS ====================
  static String determineSubtype(String type, String text) {
    final lowerText = text.toLowerCase();

    if (type == 'personal_expense') {
      if (lowerText.contains('comida') || lowerText.contains('restaurante'))
        return 'food';
      if (lowerText.contains('transporte') || lowerText.contains('gasolina'))
        return 'transport';
      if (lowerText.contains('servicio') ||
          lowerText.contains('luz') ||
          lowerText.contains('agua'))
        return 'bill';
      if (lowerText.contains('compras') || lowerText.contains('super'))
        return 'shopping';
    }

    if (type == 'loan_given' || type == 'loan_received') {
      if (lowerText.contains('familiar')) return 'family_loan';
      if (lowerText.contains('amigo')) return 'friend_loan';
      if (lowerText.contains('trabajo')) return 'business_loan';
    }

    return 'general';
  }

  // ==================== DETERMINACIÓN DE SUBCATEGORÍAS ====================
  static String determineSubcategory(String category, String text) {
    final lowerText = text.toLowerCase();

    switch (category) {
      case 'food':
        if (lowerText.contains('restaurante')) return 'restaurant';
        if (lowerText.contains('super')) return 'groceries';
        if (lowerText.contains('café') || lowerText.contains('cafe'))
          return 'coffee';
        return 'general';
      case 'transport':
        if (lowerText.contains('gasolina')) return 'fuel';
        if (lowerText.contains('uber') || lowerText.contains('taxi'))
          return 'ride';
        if (lowerText.contains('estacionamiento')) return 'parking';
        return 'general';
      default:
        return 'general';
    }
  }

  // ==================== DETERMINACIÓN DE TIPO DE PERSONA ====================
  static String determinePersonType(String? person, String text) {
    if (person == null) return 'unknown';

    final lowerText = text.toLowerCase();
    if (lowerText.contains('amigo') || lowerText.contains('amiga'))
      return 'friend';
    if (lowerText.contains('familia') ||
        lowerText.contains('hermano') ||
        lowerText.contains('hermana'))
      return 'family';
    if (lowerText.contains('compañero') || lowerText.contains('trabajo'))
      return 'coworker';
    if (lowerText.contains('proveedor') || lowerText.contains('negocio'))
      return 'business';
    if (lowerText.contains('arrendador') || lowerText.contains('casero'))
      return 'landlord';

    return 'other';
  }

  // ==================== DETERMINACIÓN DE PAGADOR ====================
  static String? determinePayer(String text, String type) {
    final lowerText = text.toLowerCase();

    if (type == 'income' || type == 'loan_received') {
      if (lowerText.contains('trabajo') || lowerText.contains('empresa'))
        return 'employer';
      if (lowerText.contains('cliente')) return 'client';
      if (lowerText.contains('banco')) return 'bank';
    }

    return null;
  }

  // ==================== DETERMINACIÓN DE RECEPTOR ====================
  static String? determinePayee(String text, String type) {
    final lowerText = text.toLowerCase();

    if (type == 'personal_expense' || type == 'payment_to_person') {
      if (lowerText.contains('proveedor')) return 'supplier';
      if (lowerText.contains('servicio')) return 'service_provider';
    }

    return null;
  }

  // ==================== EXTRACCIÓN DE CANTIDAD DE PARTICIPANTES ====================
  static int extractParticipantCount(String text) {
    final lowerText = text.toLowerCase();
    final patterns = [
      RegExp(r'entre\s+(\d+)\s+personas'),
      RegExp(r'(\d+)\s+personas'),
      RegExp(r'con\s+(\d+)\s+amigos'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(lowerText);
      if (match != null) {
        final count = int.tryParse(match.group(1)!);
        if (count != null && count > 1) return count;
      }
    }

    // Por defecto, si es compartido asumir 2 personas
    return lowerText.contains('compartido') || lowerText.contains('entre todos')
        ? 2
        : 1;
  }

  // ==================== DETERMINACIÓN DE MÉTODO DE PAGO ====================
  static String determinePaymentMethod(String text) {
    final lowerText = text.toLowerCase();

    if (lowerText.contains('efectivo') || lowerText.contains('cash'))
      return 'cash';
    if (lowerText.contains('tarjeta') || lowerText.contains('card'))
      return 'card';
    if (lowerText.contains('transferencia')) return 'transfer';
    if (lowerText.contains('paypal') || lowerText.contains('mercado pago'))
      return 'digital_wallet';

    return 'other';
  }

  // ==================== EXTRACCIÓN DE TAGS ====================
  static List<String> extractTags(String text, String category) {
    final tags = <String>[];
    final lowerText = text.toLowerCase();

    // Tags basados en categoría
    tags.add(category);

    // Tags basados en contenido
    if (lowerText.contains('urgente') || lowerText.contains('inmediato'))
      tags.add('urgent');
    if (lowerText.contains('importante')) tags.add('important');
    if (lowerText.contains('trabajo') || lowerText.contains('negocio'))
      tags.add('business');
    if (lowerText.contains('personal')) tags.add('personal');
    if (lowerText.contains('recurrente')) tags.add('recurring');

    return tags;
  }

  // ==================== EXTRACCIÓN DE UBICACIÓN ====================
  static String? extractLocation(String text) {
    final lowerText = text.toLowerCase();

    if (lowerText.contains('restaurante')) return 'Restaurante';
    if (lowerText.contains('supermercado') || lowerText.contains('super'))
      return 'Supermercado';
    if (lowerText.contains('gasolinera')) return 'Gasolinera';
    if (lowerText.contains('casa')) return 'Casa';
    if (lowerText.contains('trabajo') || lowerText.contains('oficina'))
      return 'Oficina';

    return null;
  }

  // ==================== GENERACIÓN DE ACCIONES SUGERIDAS ====================
  static List<String> generateSuggestedActions(
    String type,
    List<String> missingInfo,
  ) {
    final actions = <String>[];

    if (missingInfo.contains('amount')) {
      actions.add('solicitar_monto');
    }
    if (missingInfo.contains('target_person')) {
      actions.add('solicitar_persona');
    }
    if (missingInfo.contains('title')) {
      actions.add('solicitar_titulo');
    }

    // Acciones específicas por tipo
    switch (type) {
      case 'shared_expense':
      case 'split_bill':
        actions.add('definir_participantes');
        actions.add('configurar_division');
        break;
      case 'loan_given':
      case 'loan_received':
        actions.add('definir_plazo');
        actions.add('establecer_interes');
        break;
    }

    return actions;
  }

  // ==================== OBTENCIÓN DE ICONOS ====================
  static String getIconForType(String type) {
    switch (type) {
      case 'personal_expense':
        return '💰';
      case 'income':
        return '💵';
      case 'shared_expenses':
        return '👥';
      case 'payment_to_person':
        return '💸';
      case 'loan':
        return '📤';
      case 'money_request':
        return '📨';
      case 'split_bill':
        return '🍽️';
      default:
        return '📋';
    }
  }

  // ==================== OBTENCIÓN DE COLORES ====================
  static String getColorForType(String type) {
    switch (type) {
      case 'expense':
        return '#FF6B6B';
      case 'income':
        return '#4ECDC4';
      case 'shared_expense':
        return '#45B7D1';
      case 'payment_to_person':
        return '#96CEB4';
      case 'loan_given':
        return '#FFEAA7';
      case 'loan_received':
        return '#DDA0DD';
      default:
        return '#95A5A6';
    }
  }

  // ==================== ANÁLISIS DE FALLBACK ====================
  static Map<String, dynamic> createFallbackAnalysis(String text) {
    return {
      'transaction_type': 'personal_expense',
      'title': 'Transacción de voz',
      'description': text,
      'category': 'other',
      'confidence': 0.3,
      'user_message': 'Comando básico procesado',
    };
  }
}
