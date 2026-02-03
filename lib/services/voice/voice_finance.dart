// lib/services/voice_finance_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:record/record.dart';
import 'package:walleta/utils/voice_text_parser.dart';

class VoiceFinanceService {
  late final AudioRecorder _audioRecorder;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _groqApiKey = 'API_KEY :)';
  static const String _groqBaseUrl = 'https://api.groq.com/openai/v1';
  static const String _transcriptionModel = 'whisper-large-v3-turbo';
  static const String _chatModel = 'llama-3.3-70b-versatile';

  bool _isRecording = false;

  VoiceFinanceService() {
    _audioRecorder = AudioRecorder();
  }

  // ==================== MÉTODOS PRINCIPALES ====================
  Future<void> startRecording() async {
    try {
      if (_isRecording) return;

      final permission = await _audioRecorder.hasPermission();
      // if (permission != RecordPermission.granted) {
      //   await _audioRecorder.requestPermission();
      // }

      final config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 16000,
        bitRate: 128000,
        numChannels: 1,
      );

      final tempDir = Directory.systemTemp;
      final filePath =
          '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(config, path: filePath);
      _isRecording = true;

      print('🎤 Grabación iniciada');
    } catch (e) {
      print('❌ Error al grabar: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> stopRecordingAndProcess() async {
    try {
      if (!_isRecording) {
        return {'success': false, 'error': 'No hay grabación activa'};
      }

      print('🛑 Deteniendo grabación...');
      final audioPath = await _audioRecorder.stop();
      _isRecording = false;

      if (audioPath == null) {
        throw Exception('No se pudo obtener el archivo de audio');
      }

      await Future.delayed(Duration(milliseconds: 500));

      // 1. Transcribir
      print('🔊 Transcribiendo...');
      final transcription = await _transcribeAudio(audioPath);
      if (transcription.trim().isEmpty) {
        throw Exception('No se detectó voz');
      }

      print('📝 Transcripción: "$transcription"');

      // 2. Analizar con IA para extraer datos estructurados
      print('🤖 Analizando comando...');
      final structuredData = await _analyzeFinancialCommand(transcription);

      // 3. Validar y procesar
      final validatedData = _validateStructuredData(
        structuredData,
        transcription,
      );

      // 4. Guardar en Firebase
      final user = _auth.currentUser;
      if (user != null) {
        print('💾 Guardando datos...');
        await _saveFinancialData(user.uid, validatedData);
      }

      return {
        'success': true,
        'transcription': transcription,
        'data': validatedData,
        'message':
            validatedData['user_message']?.toString() ?? 'Comando procesado',
      };
    } catch (e) {
      print('❌ Error: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Error procesando comando',
      };
    }
  }

  // ==================== ANÁLISIS AVANZADO CON IA ====================
  Future<Map<String, dynamic>> _analyzeFinancialCommand(String text) async {
    try {
      final prompt = '''
Analiza este comando de voz financiero y extrae TODA la información relevante:

TEXTO: "$text"

INSTRUCCIONES:
1. Identifica el TIPO de operación financiera
2. Extrae TODOS los datos mencionados
3. Si falta información importante, indícalo
4. Usa valores nulos (null) para datos no mencionados

DEVUELVE SOLO UN OBJETO JSON con esta estructura:

{
  "transaction_type": "personal_expense|income|shared_expenses|payment_to_person|loan|money_request|budget_setting|balance_check|split_bill|invalid",

  "is_shared": true/false,

  "is_payment_to_person": true/false,

  "is_loan": true/false,

  "amount": número_o_null,
  
  "title": "título descriptivo extraído del texto",

  "description": "descripción detallada",

  "category": "food|transport|housing|entertainment|shopping|health|education|salary|business|investment|savings|debt|other",

  "date": "YYYY-MM-DD_o_null (solo si se menciona fecha específica)",

  "due_date": "YYYY-MM-DD_o_null (para préstamos o pagos futuros)",

  "target_person": "nombre_o_null (persona involucrada)",
  
  "target_person_type": "friend|family|coworker|business|creditor|debtor|landlord|employee|other",

  "is_recurring": true/false,

  "recurrence": "daily|weekly|monthly|yearly|null",

  "priority": "low|medium|high|urgent",

  "notes": "notas adicionales",

  "receipt_available": true/false,

  "requires_confirmation": true/false,

  "is_important": true/false,

  "confidence": 0.0_a_1.0,
  
  "missing_info": ["campo1", "campo2"]_o_null,

  "suggested_actions": ["acción1", "acción2"]_o_null,

  "user_message": "mensaje amigable para el usuario"
}

EJEMPLOS DE ANÁLISIS:

1. "Le presté 500 pesos a Juan para la comida" →
{
  "transaction_type": "loan_given",
  "is_shared": false,
  "is_payment_to_person": true,
  "is_loan": true,
  "amount": 500,
  "currency": "MXN",
  "title": "Préstamo a Juan",
  "description": "Préstamo para comida",
  "category": "food",
  "target_person": "Juan",
  "target_person_type": "friend",
  "confidence": 0.95
}

2. "Voy a pagar 300 de la luz que debemos entre todos el 15 de enero" →
{
  "transaction_type": "shared_expense",
  "is_shared": true,
  "amount": 300,
  "currency": "MXN",
  "title": "Pago de luz compartido",
  "description": "Pago de servicio de luz",
  "category": "housing",
  "date": "${DateTime.now().year}-01-15",
  "split_type": "equal",
  "confidence": 0.9
}

3. "María me debe pagar 800 por el concierto del viernes" →
{
  "transaction_type": "money_request",
  "is_payment_to_person": true,
  "amount": 800,
  "title": "Deuda de María por concierto",
  "description": "Pendiente de pago por entradas de concierto",
  "category": "entertainment",
  "target_person": "María",
  "due_date": "fecha_del_viernes",
  "confidence": 0.85
}

4. "Gasté 150 en gasolina para el carro" →
{
  "transaction_type": "personal_expense",
  "is_shared": false,
  "amount": 150,
  "title": "Gasolina para carro",
  "description": "Recarga de combustible",
  "category": "transport",
  "confidence": 0.98
}

5. "Vamos a dividir la cena de 1200 entre 4 personas" →
{
  "transaction_type": "split_bill",
  "is_shared": true,
  "amount": 1200,
  "title": "Cena compartida",
  "description": "División de cuenta de cena",
  "category": "food",
  "confidence": 0.88
}

6. "Recibí 5000 de mi trabajo el primer día del mes" →
{
  "transaction_type": "income",
  "amount": 5000,
  "title": "Salario mensual",
  "description": "Pago por trabajo",
  "category": "salary",
  "date": "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-01",
  "is_recurring": true,
  "recurrence": "monthly",
  "confidence": 0.92
}

7. "Apunté 3000 de unas copas con unos compañeros" →
{
  "transaction_type": "shared_expenses",
  "is_shared": true,
  "amount": 3000,
  "title": "Copas con compañeros",
  "description": "Copas compartidas con compañeros",
  "category": "entertainment",
  "confidence": 0.97
}

ANALIZA ESTE TEXTO: "$text"
''';

      final response = await http.post(
        Uri.parse('$_groqBaseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqApiKey',
        },
        body: jsonEncode({
          'model': _chatModel,
          'messages': [
            {
              'role': 'system',
              'content':
                  'Eres un analizador financiero inteligente. Extrae TODA la información estructurada del texto. Devuelve SOLO JSON válido sin texto adicional.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.1,
          'max_tokens': 1000,
          'response_format': {'type': 'json_object'},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];

        try {
          final jsonResult = jsonDecode(content) as Map<String, dynamic>;
          print('✅ JSON recibido: ${jsonEncode(jsonResult)}');
          return jsonResult;
        } catch (e) {
          print('❌ Error parseando JSON: $e');
          return VoiceTextParser.createFallbackAnalysis(text);
        }
      } else {
        throw Exception('Error API: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en análisis: $e');
      return VoiceTextParser.createFallbackAnalysis(text);
    }
  }

  // ==================== VALIDACIÓN Y COMPLETADO ====================
  Map<String, dynamic> _validateStructuredData(
    Map<String, dynamic> data,
    String originalText,
  ) {
    // Validar tipos de transacción
    const validTransactionTypes = [
      'personal_expense',
      'income',
      'shared_expenses',
      'split_bill',
      'payment_to_person',
      'loan',
      'money_request',
      // 'budget_setting',
      // 'balance_check',
      // 'invalid',
    ];

    String type =
        data['transaction_type']?.toString().toLowerCase() ?? 'invalid';
    if (!validTransactionTypes.contains(type)) {
      type = 'invalid';
    }

    final isActuallyShared = VoiceTextParser.detectSharedExpense(originalText);
    if (isActuallyShared && type == 'personal_expense') {
      print(
        '⚠️ Corrigiendo tipo: $type → shared_expenses (detectado en texto)',
      );
      type = 'shared_expenses';
      data['is_shared'] = true; // También actualizar el flag
    }

    // Validar categorías
    const validCategories = [
      'food',
      'transport',
      'housing',
      'entertainment',
      'shopping',
      'health',
      'education',
      'salary',
      'business',
      'investment',
      'savings',
      'debt',
      'other',
    ];

    String category = data['category']?.toString().toLowerCase() ?? 'other';
    if (!validCategories.contains(category)) {
      category = 'other';
    }

    // Extraer y validar monto
    double? amount;
    if (data['amount'] != null) {
      if (data['amount'] is num) {
        amount = data['amount'].toDouble();
      } else if (data['amount'] is String) {
        // Extraer números incluyendo decimales
        final regex = RegExp(r'(\d+([.,]\d+)?)');
        final matches = regex.allMatches(data['amount']);
        if (matches.isNotEmpty) {
          final numberStr = matches.first.group(0)!.replaceAll(',', '.');
          amount = double.tryParse(numberStr);
        }
      }
    }

    // Extraer nombres de personas (más inteligente)
    String? targetPerson = data['target_person']?.toString();
    if (targetPerson == null || targetPerson.isEmpty) {
      // Intentar extraer nombres del texto
      final personRegex = RegExp(
        r'\b(a|para|de|con)\s+([A-ZÁÉÍÓÚÑ][a-záéíóúñ]+(?:\s+[A-ZÁÉÍÓÚÑ][a-záéíóúñ]+)*)\b',
        caseSensitive: false,
      );

      final matches = personRegex.allMatches(originalText);
      if (matches.isNotEmpty) {
        // Tomar el nombre más probable (generalmente el segundo grupo)
        for (final match in matches) {
          if (match.groupCount >= 2) {
            final possibleName = match.group(2);
            if (possibleName != null &&
                !VoiceTextParser.isCommonWord(possibleName.toLowerCase()) &&
                possibleName.length > 2) {
              targetPerson = possibleName;
              break;
            }
          }
        }
      }
    }

    // Procesar fecha si se menciona
    String? date = data['date']?.toString();
    if (date == null || date.isEmpty) {
      // Intentar extraer fechas del texto
      date = VoiceTextParser.extractDateFromText(originalText);
    }

    // Generar título si no viene
    String title = data['title']?.toString().trim() ?? '';
    if (title.isEmpty) {
      title = VoiceTextParser.generateTitle(
        type,
        amount,
        category,
        targetPerson,
      );
    }

    // Generar descripción si no viene
    String description = data['description']?.toString().trim() ?? '';
    if (description.isEmpty) {
      description = VoiceTextParser.generateDescription(
        type,
        originalText,
        amount,
        targetPerson,
      );
    }

    // Determinar si es compartido
    bool isShared =
        data['is_shared'] == true ||
        type.contains('shared') ||
        type.contains('split') ||
        originalText.toLowerCase().contains('entre todos') ||
        originalText.toLowerCase().contains('dividir') ||
        originalText.toLowerCase().contains('compartido');

    // Determinar si es préstamo
    bool isLoan =
        data['is_loan'] == true ||
        type.contains('loan') ||
        originalText.toLowerCase().contains('prest') ||
        originalText.toLowerCase().contains('debe') ||
        originalText.toLowerCase().contains('préstamo');

    // Determinar si es pago a persona
    bool isPaymentToPerson =
        data['is_payment_to_person'] == true ||
        targetPerson != null ||
        originalText.toLowerCase().contains('a ') ||
        originalText.toLowerCase().contains('para ') ||
        originalText.toLowerCase().contains('le ');

    // Mensaje para el usuario
    String userMessage =
        data['user_message']?.toString() ??
        VoiceTextParser.generateUserMessage(
          type,
          amount,
          category,
          targetPerson,
          isShared,
        );

    // Validar confianza
    double confidence = (data['confidence'] as num?)?.toDouble() ?? 0.5;
    confidence = confidence.clamp(0.0, 1.0);

    // Información faltante
    List<String> missingInfo = [];
    if (amount == null &&
        (type == 'personal_expense' ||
            type == 'income' ||
            type == 'shared_expenses')) {
      missingInfo.add('amount');
    }
    if ((targetPerson == null || targetPerson.isEmpty) &&
        (isPaymentToPerson || isLoan)) {
      missingInfo.add('target_person');
    }
    if (title.isEmpty) {
      missingInfo.add('title');
    }

    // Construir resultado final con valores seguros
    final result = {
      // Datos principales
      'transaction_type': type,
      'transaction_subtype': VoiceTextParser.determineSubtype(
        type,
        originalText,
      ),
      'is_shared': isShared,
      'is_loan': isLoan,
      'is_payment_to_person': isPaymentToPerson,
      'is_split_bill': type == 'split_bill',

      // Información financiera
      'amount': amount,
      'currency': data['currency']?.toString() ?? 'MXN',
      'amount_currency':
          amount != null
              ? '${amount.toStringAsFixed(2)} ${data['currency']?.toString() ?? 'MXN'}'
              : null,

      // Detalles descriptivos
      'title': title,
      'description': description,
      'category': category,
      'subcategory':
          data['subcategory']?.toString() ??
          VoiceTextParser.determineSubcategory(category, originalText),

      // Fechas
      'date': date ?? DateTime.now().toIso8601String().split('T')[0],
      'due_date': data['due_date']?.toString(),
      'created_at': DateTime.now().toIso8601String(),

      // Personas involucradas
      'target_person': targetPerson,
      'target_person_type':
          data['target_person_type']?.toString() ??
          VoiceTextParser.determinePersonType(targetPerson, originalText),
      'payer': VoiceTextParser.determinePayer(originalText, type),
      'payee': VoiceTextParser.determinePayee(originalText, type),

      // División de gastos
      'split_type': data['split_type']?.toString(),
      'split_details': data['split_details'],
      'total_participants': VoiceTextParser.extractParticipantCount(
        originalText,
      ),

      // Métodos y configuraciones
      'payment_method':
          data['payment_method']?.toString() ??
          VoiceTextParser.determinePaymentMethod(originalText),
      'is_recurring': data['is_recurring'] ?? false,
      'recurrence': data['recurrence']?.toString(),
      'priority': data['priority']?.toString() ?? 'medium',

      // Metadatos
      'tags':
          (data['tags'] as List?)?.map((e) => e.toString()).toList() ??
          VoiceTextParser.extractTags(originalText, category),
      'notes': data['notes']?.toString() ?? originalText,
      'location':
          data['location']?.toString() ??
          VoiceTextParser.extractLocation(originalText),
      'receipt_available': data['receipt_available'] ?? false,
      'requires_confirmation':
          data['requires_confirmation'] ?? (amount != null && amount > 1000),
      'is_important': data['is_important'] ?? false,

      // Información de calidad
      'confidence': confidence,
      'missing_info':
          missingInfo.isNotEmpty
              ? missingInfo
              : (data['missing_info'] as List?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  [],
      'suggested_actions':
          (data['suggested_actions'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          VoiceTextParser.generateSuggestedActions(type, missingInfo),
      'original_text': originalText,
      'is_complete': missingInfo.isEmpty,

      // Para la UI
      'user_message': userMessage,
      'action_required': missingInfo.isNotEmpty ? 'need_more_info' : 'none',
      'icon': VoiceTextParser.getIconForType(type),
      'color': VoiceTextParser.getColorForType(type),
    };

    print('✅ Datos validados:');
    print('   Tipo: $type');
    print('   Monto: $amount');
    print('   Persona: $targetPerson');
    print('   Compartido: $isShared');
    print('   Préstamo: $isLoan');
    print('   Confianza: $confidence');

    return result;
  }

  // ==================== TRANSCRIPCIÓN ====================
  Future<String> _transcribeAudio(String audioPath) async {
    try {
      final audioFile = File(audioPath);
      final bytes = await audioFile.readAsBytes();

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_groqBaseUrl/audio/transcriptions'),
      );

      request.headers['Authorization'] = 'Bearer $_groqApiKey';
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: 'audio.m4a'),
      );

      request.fields.addAll({
        'model': _transcriptionModel,
        'language': 'es',
        'response_format': 'json',
        'temperature': '0',
      });

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return data['text']?.toString().trim() ?? '';
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Error transcripción: $e');
      return '';
    }
  }

  // ==================== GUARDAR EN FIRESTORE ====================
  Future<void> _saveFinancialData(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      final collection = _firestore.collection('financial_transactions');

      final transactionData = {
        'user_id': userId,
        ...data,
        'firebase_timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
        'synced': false,
      };

      await collection.add(transactionData);
      print('✅ Datos guardados en Firestore');
    } catch (e) {
      print('❌ Error guardando: $e');
    }
  }

  // ==================== UTILIDADES ====================
  Future<void> cancelRecording() async {
    if (_isRecording) {
      await _audioRecorder.stop();
      _isRecording = false;
    }
  }

  Future<void> dispose() async {
    await cancelRecording();
    await _audioRecorder.dispose();
  }

  bool get isRecording => _isRecording;
}
