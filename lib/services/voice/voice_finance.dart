// lib/services/voice_finance_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:walleta/utils/voice_text_parser.dart';
import 'package:path_provider/path_provider.dart';

class VoiceFinanceService {
  late final AudioRecorder _audioRecorder;

  static const String _groqApiKey = 'api key';
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

      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        throw Exception('Sin permisos de micrófono');
      }

      final config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        sampleRate: 16000,
        bitRate: 128000,
        numChannels: 1,
      );

      final dir = await getTemporaryDirectory();
      final filePath =
          '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(config, path: filePath);

      _isRecording = true;
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

      // // 4. Guardar en Firebase
      // final user = _auth.currentUser;
      // if (user != null) {
      //   print('💾 Guardando datos...');
      //   await _saveFinancialData(user.uid, validatedData);
      // }

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

  Future<Map<String, dynamic>> _analyzeFinancialCommand(String text) async {
    try {
      // PROMPT OPTIMIZADO con nombres EXACTOS
      final prompt = '''
Analiza "$text" y extrae datos financieros. Responde SOLO con JSON.

ESTRUCTURA:
{
  "transaction_type": "personal_expense|income|shared_expenses|loan|payment_to_person|invalid",
  "amount": number/null,
  "title": "string",
  "desc": "string",
  "category": "food|transport|home|entertainment|services|shopping|health|income|other",
  "person": "string/null",
  "date": "YYYY-MM-DD/null",
  "due_date": "YYYY-MM-DD/null",
  "is_shared": true/false,
  "is_loan": true/false,
  "is_payment_to_person": true/false,
  "is_recurring": true/false,
  "priority": "low|medium|high",
  "missing_info": ["field1", "field2"]/null,
  "user_message": "string"
}

EJEMPLOS:
1. "Le presté 500 a Juan" → {"transaction_type":"loan","amount":500,"title":"Préstamo a Juan","desc":"Préstamo","category":"other","person":"Juan","is_shared":false,"is_loan":true,"is_payment_to_person":true}
2. "Gasté 150 en gasolina" → {"transaction_type":"personal_expense","amount":150,"title":"Gasolina","desc":"Combustible","category":"transport","is_shared":false}
3. "Dividir 1200 entre 4" → {"transaction_type":"shared_expenses","amount":1200,"title":"Cena compartida","desc":"División de cuenta","category":"food","is_shared":true}
4. "Recibí 5000 de salario" → {"transaction_type":"income","amount":5000,"title":"Salario","desc":"Pago trabajo","category":"income","is_recurring":true}
5. "Voy a pagar a María 300" → {"transaction_type":"payment_to_person","amount":300,"title":"Pago a María","desc":"Pago","category":"other","person":"María","is_payment_to_person":true}

ANALIZA: "$text"
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
                  'Eres un analizador financiero. Devuelve SOLO JSON con la estructura exacta solicitada.',
            },
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.1,
          'max_tokens': 500,
          'response_format': {'type': 'json_object'},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];

        final jsonResult = jsonDecode(content) as Map<String, dynamic>;

        // Transformar al formato original (ya está casi listo)
        return _transformToOriginalFormat(jsonResult);
      } else {
        throw Exception('Error API: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error en análisis: $e');
      return _createFallbackAnalysis(text);
    }
  }

  Map<String, dynamic> _transformToOriginalFormat(Map<String, dynamic> simple) {
    // Mapeo de categorías en inglés a español
    final categoryMap = {
      'food': 'comida',
      'transport': 'transporte',
      'home': 'hogar',
      'entertainment': 'entretenimiento',
      'services': 'servicios',
      'shopping': 'compras',
      'health': 'salud',
      'income': 'ingreso',
      'other': 'otros',
    };

    // Ya tenemos los nombres correctos, solo mapeamos categorías
    return {
      'transaction_type': simple['transaction_type'] ?? 'invalid',
      'is_shared': simple['is_shared'] ?? false,
      'is_payment_to_person': simple['is_payment_to_person'] ?? false,
      'is_loan': simple['is_loan'] ?? false,
      'amount': simple['amount'],
      'title': simple['title'] ?? 'Transacción',
      'description': simple['desc'] ?? simple['title'] ?? '',
      'category': categoryMap[simple['category']] ?? 'otros',
      'date': simple['date'],
      'due_date': simple['due_date'],
      'target_person': simple['person'],
      'is_recurring': simple['is_recurring'] ?? false,
      'recurrence': simple['is_recurring'] == true ? 'monthly' : null,
      'priority': simple['priority'] ?? 'medium',
      'notes': '',
      'receipt_available': false,
      'requires_confirmation':
          (simple['amount'] as num?)?.toDouble() ?? 0 > 1000,
      'is_important':
          simple['priority'] == 'high' || simple['priority'] == 'urgent',

      'missing_info': simple['missing_info'],
      'suggested_actions': _generateSuggestedActions(simple),
      'user_message': simple['user_message'] ?? 'Transacción procesada',
    };
  }

  List<String>? _generateSuggestedActions(Map<String, dynamic> data) {
    final missing = data['missing_info'] as List?;
    if (missing != null && missing.isNotEmpty) {
      return ['Completar información faltante'];
    }
    return null;
  }

  Map<String, dynamic> _createFallbackAnalysis(String text) {
    return {
      'transaction_type': 'invalid',
      'is_shared': false,
      'is_payment_to_person': false,
      'is_loan': false,
      'amount': null,
      'title': 'Error en análisis',
      'description': text,
      'category': 'otros',
      'date': null,
      'due_date': null,
      'target_person': null,
      'is_recurring': false,
      'recurrence': null,
      'priority': 'medium',
      'notes': '',
      'receipt_available': false,
      'requires_confirmation': false,
      'is_important': false,
      'missing_info': ['all'],
      'suggested_actions': ['Intentar nuevamente'],
      'user_message': 'No se pudo analizar el comando',
    };
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
      // 'money_request',
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

    // Validar categorías (ACTUALIZAR a español)
    const validCategories = [
      'compras',
      'comida',
      'restaurante',
      'entretenimiento',
      'hogar',
      'transporte',
      'servicios',
      'salud',
      'educación',
      'ropa',
      'deportes',
      'viajes',
      'regalos',
      'mascotas',
      'ingreso',
      'negocios',
      'inversiones',
      'ahorro',
      'seguros',
      'impuestos',
      'cuotas',
      'deuda',
      'otros',
    ];

    String category = data['category']?.toString().toLowerCase() ?? 'otros';

    // Si la categoría no es válida, usar 'otros'
    if (!validCategories.contains(category)) {
      category = 'otros';
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

    //! Construir resultado final con valores seguros
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
      'currency': data['currency']?.toString() ?? 'CRC',
      'amount_currency':
          amount != null
              ? '${amount} ${data['currency']?.toString() ?? 'CRC'}'
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
    };

    print('✅ Datos validados:');
    print('   Tipo: $type');
    print('   Monto: $amount');
    print('   Persona: $targetPerson');
    print('   Compartido: $isShared');
    print('   Préstamo: $isLoan');

    return result;
  }

  // ==================== TRANSCRIPCIÓN ====================
  Future<String> _transcribeAudio(String audioPath) async {
    try {
      print('🎤 Intentando transcribir audio de: $audioPath');

      // 1. Verificar si el archivo existe
      final audioFile = File(audioPath);
      final fileExists = await audioFile.exists();

      if (!fileExists) {
        print('❌ Archivo de audio no encontrado en: $audioPath');
        throw Exception('Archivo de audio no encontrado');
      }

      // 2. Verificar tamaño del archivo
      final fileSize = await audioFile.length();
      if (fileSize == 0) {
        print('❌ Archivo de audio vacío (0 bytes)');
        throw Exception('Archivo de audio vacío');
      }

      print('📁 Archivo encontrado, tamaño: ${fileSize} bytes');

      // 3. Leer bytes
      final bytes = await audioFile.readAsBytes();

      // 4. Crear request
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

      print('🚀 Enviando audio a Groq API...');
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('📥 Respuesta recibida, status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        final transcribedText = data['text']?.toString().trim() ?? '';

        print('✅ Transcripción exitosa: ${transcribedText.length} caracteres');
        return transcribedText;
      } else {
        print('❌ Error de API: ${response.statusCode} - $responseBody');
        throw Exception('Error ${response.statusCode}: $responseBody');
      }
    } catch (e) {
      print('⚠️ Error en transcripción: $e');
      print('📌 Stack trace: ${e.toString()}');
      return '';
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
