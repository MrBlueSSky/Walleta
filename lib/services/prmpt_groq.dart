  //   // ==================== ANÁLISIS AVANZADO CON IA ====================
  //   Future<Map<String, dynamic>> _analyzeFinancialCommand(String text) async {
  //     try {
  //       final prompt = '''
  // Analiza este comando de voz financiero y extrae TODA la información relevante:

  // TEXTO: "$text"

  // INSTRUCCIONES:
  // 1. Identifica el TIPO de operación financiera
  // 2. Extrae TODOS los datos mencionados
  // 3. Si falta información importante, indícalo
  // 4. Usa valores nulos (null) para datos no mencionados

  // DEVUELVE SOLO UN OBJETO JSON con esta estructura:

  // {
  //   "transaction_type": "personal_expense|income|shared_expenses|payment_to_person|loan|budget_setting|balance_check|split_bill|invalid",

  //   "is_shared": true/false,

  //   "is_payment_to_person": true/false,

  //   "is_loan": true/false,

  //   "amount": número_o_null,

  //   "title": "título descriptivo extraído del texto",

  //   "description": "descripción detallada",

  // "category": "compras|comida|restaurante|entretenimiento|hogar|transporte|servicios|salud|educación|ropa|deportes|viajes|regalos|mascotas|ingreso|negocios|inversiones|ahorro|seguros|impuestos|cuotas|deuda|otros",

  //   "date": "YYYY-MM-DD_o_null (solo si se menciona fecha específica)",

  //   "due_date": "YYYY-MM-DD_o_null (para préstamos o pagos futuros)",

  //   "target_person": "nombre_o_null (persona involucrada)",

  //   "target_person_type": "friend|family|coworker|business|creditor|debtor|landlord|employee|other",

  //   "is_recurring": true/false,

  //   "recurrence": "daily|weekly|monthly|yearly|null",

  //   "priority": "low|medium|high|urgent",

  //   "notes": "notas adicionales",

  //   "receipt_available": true/false,

  //   "requires_confirmation": true/false,

  //   "is_important": true/false,

  //   "confidence": 0.0_a_1.0,

  //   "missing_info": ["campo1", "campo2"]_o_null,

  //   "suggested_actions": ["acción1", "acción2"]_o_null,

  //   "user_message": "mensaje amigable para el usuario"
  // }

  // EJEMPLOS DE ANÁLISIS:

  // 1. "Le presté 500 pesos a Juan para la comida" →
  // {
  //   "transaction_type": "loan_given",
  //   "is_shared": false,
  //   "is_payment_to_person": true,
  //   "is_loan": true,
  //   "amount": 500,
  //   "currency": "CRC",
  //   "title": "Préstamo a Juan",
  //   "description": "Préstamo para comida",
  //   "category": "comida",
  //   "target_person": "Juan",
  //   "target_person_type": "friend",
  //   "confidence": 0.95
  // }

  // 2. "Voy a pagar 300 de la luz que debemos entre todos el 15 de enero" →
  // {
  //   "transaction_type": "shared_expense",
  //   "is_shared": true,
  //   "amount": 300,
  //   "currency": "CRC",
  //   "title": "Pago de luz compartido",
  //   "description": "Pago de servicio de luz",
  //   "category": "hogar",
  //   "date": "${DateTime.now().year}-01-15",
  //   "split_type": "equal",
  //   "confidence": 0.9
  // }

  // 3. "María me debe pagar 800 por el concierto del viernes" →
  // {
  //   "transaction_type": "loan",
  //   "is_payment_to_person": true,
  //   "amount": 800,
  //   "title": "Deuda de María por concierto",
  //   "description": "Pendiente de pago por entradas de concierto",
  //   "category": "entretenimiento",
  //   "target_person": "María",
  //   "due_date": "fecha_del_viernes",
  //   "confidence": 0.85
  // }

  // 4. "Gasté 150 en gasolina para el carro" →
  // {
  //   "transaction_type": "personal_expense",
  //   "is_shared": false,
  //   "amount": 150,
  //   "title": "Gasolina para carro",
  //   "description": "Recarga de combustible",
  //   "category": "transporte",
  //   "confidence": 0.98
  // }

  // 5. "Vamos a dividir la cena de 1200 entre 4 personas" →
  // {
  //   "transaction_type": "split_bill",
  //   "is_shared": true,
  //   "amount": 1200,
  //   "title": "Cena compartida",
  //   "description": "División de cuenta de cena",
  //   "category": "comida",
  //   "confidence": 0.88
  // }

  // 6. "Recibí 5000 de mi trabajo el primer día del mes" →
  // {
  //   "transaction_type": "income",
  //   "amount": 5000,
  //   "title": "Salario mensual",
  //   "description": "Pago por trabajo",
  //   "category": "ingreso",
  //   "date": "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-01",
  //   "is_recurring": true,
  //   "recurrence": "monthly",
  //   "confidence": 0.92
  // }

  // 7. "Apunté 3000 de unas copas con unos compañeros" →
  // {
  //   "transaction_type": "shared_expenses",
  //   "is_shared": true,
  //   "amount": 3000,
  //   "title": "Copas con compañeros",
  //   "description": "Copas compartidas con compañeros",
  //   "category": "entretenimiento",
  //   "confidence": 0.97
  // }

  // 8. "Angelica Rojas me pidio 3000" →
  // {
  //   "transaction_type": "loan",
  //   "is_payment_to_person": true,
  //   "amount": 3000,
  //   "title": "Deuda de Angelica Rojas",
  //   "description": "Pendiente de pago por entradas de concierto",
  //   "category": "otros",
  //   "target_person": "Angelica Rojas",
  //   "due_date": null,
  //   "confidence": 0.85
  // }

  // ANALIZA ESTE TEXTO: "$text"
  // ''';

  //       final response = await http.post(
  //         Uri.parse('$_groqBaseUrl/chat/completions'),
  //         headers: {
  //           'Content-Type': 'application/json',
  //           'Authorization': 'Bearer $_groqApiKey',
  //         },
  //         body: jsonEncode({
  //           'model': _chatModel,
  //           'messages': [
  //             {
  //               'role': 'system',
  //               'content':
  //                   'Eres un analizador financiero inteligente. Extrae TODA la información estructurada del texto. Devuelve SOLO JSON válido sin texto adicional.',
  //             },
  //             {'role': 'user', 'content': prompt},
  //           ],
  //           'temperature': 0.1,
  //           'max_tokens': 1000,
  //           'response_format': {'type': 'json_object'},
  //         }),
  //       );

  //       if (response.statusCode == 200) {
  //         final data = jsonDecode(response.body);
  //         final content = data['choices'][0]['message']['content'];

  //         try {
  //           final jsonResult = jsonDecode(content) as Map<String, dynamic>;
  //           print('✅ JSON recibido: ${jsonEncode(jsonResult)}');
  //           return jsonResult;
  //         } catch (e) {
  //           print('❌ Error parseando JSON: $e');
  //           // return VoiceTextParser.createFallbackAnalysis(text);
  //           return {};
  //         }
  //       } else {
  //         throw Exception('Error API: ${response.statusCode}');
  //       }
  //     } catch (e) {
  //       print('❌ Error en análisis: $e');
  //       // return VoiceTextParser.createFallbackAnalysis(text);
  //       return {};
  //     }
  //   }
