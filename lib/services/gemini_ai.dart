// // lib/services/voice_finance_service.dart
// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:record/record.dart';
// import 'package:walleta/utils/voice_text_parser.dart';

// class VoiceFinanceService {
//   late final AudioRecorder _audioRecorder;
//   String? _currentAudioPath;

//   // CONFIGURACIÓN CORRECTA DE GEMINI
//   static const String _geminiApiKey =
//       'api key xd';
//   // static const String _geminiApiKey = 'AIzaSyD...tu_key...'; // Ejemplo

//   // URLs CORRECTAS para Gemini (Feb 2024)
//   static const String _geminiBaseUrl =
//       'https://generativelanguage.googleapis.com/v1beta';

//   // Modelos disponibles (usa uno de estos):
//   // static const String _chatModel = 'gemini-1.5-flash-latest'; // Gratis, rápido
//   // static const String _chatModel = 'gemini-1.5-pro-latest';   // Más potente

//   static const String _chatModel = 'gemini-2.5-flash';

//   bool _isRecording = false;

//   VoiceFinanceService() {
//     _audioRecorder = AudioRecorder();
//   }

//   // ==================== MÉTODOS PRINCIPALES ====================
//   Future<void> startRecording() async {
//     try {
//       if (_isRecording) return;

//       final config = RecordConfig(
//         encoder: AudioEncoder.aacLc,
//         sampleRate: 16000,
//         bitRate: 128000,
//         numChannels: 1,
//       );

//       final tempDir = Directory.systemTemp;
//       _currentAudioPath =
//           '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.wav'; // Cambiar a .wav

//       await _audioRecorder.start(config, path: _currentAudioPath!);
//       _isRecording = true;

//       print('🎤 Grabación iniciada');
//     } catch (e) {
//       print('❌ Error al grabar: $e');
//       rethrow;
//     }
//   }

//   Future<Map<String, dynamic>> stopRecordingAndProcess() async {
//     try {
//       if (!_isRecording) {
//         return {'success': false, 'error': 'No hay grabación activa'};
//       }

//       print('🛑 Deteniendo grabación...');

//       // Mejor manejo del stop
//       String? audioPath;
//       try {
//         audioPath = await _audioRecorder.stop();
//       } catch (e) {
//         print('⚠️ Error en stop(), usando path guardado: $e');
//         audioPath = _currentAudioPath;
//       }

//       _isRecording = false;

//       final finalAudioPath = audioPath ?? _currentAudioPath;

//       if (finalAudioPath == null) {
//         return {
//           'success': false,
//           'error': 'No se pudo obtener audio',
//           'message': 'Intenta nuevamente',
//         };
//       }

//       print('📁 Audio en: $finalAudioPath');

//       // Verificar que el archivo existe
//       final audioFile = File(finalAudioPath);
//       if (!audioFile.existsSync()) {
//         print('⚠️ Archivo no existe: $finalAudioPath');
//         return {
//           'success': false,
//           'error': 'Archivo de audio no encontrado',
//           'message': 'Grabación falló',
//         };
//       }

//       // Pequeño delay
//       await Future.delayed(const Duration(milliseconds: 300));

//       // 1. Transcribir (usar Groq para transcripción)
//       print('🔊 Transcribiendo...');
//       String transcription;
//       try {
//         transcription = await _transcribeWithGroq(finalAudioPath);
//         if (transcription.trim().isEmpty) {
//           transcription = 'No se pudo transcribir';
//         }
//       } catch (e) {
//         print('❌ Error transcripción: $e');
//         transcription = 'Error en transcripción';
//       }

//       print('📝 Transcripción: "$transcription"');

//       if (transcription == 'No se pudo transcribir' ||
//           transcription == 'Error en transcripción') {
//         return {
//           'success': false,
//           'error': 'No se detectó voz clara',
//           'message': 'Habla más claro e intenta nuevamente',
//         };
//       }

//       // 2. Analizar con Gemini
//       print('🤖 Analizando comando...');
//       final analysisResult = await _analyzeWithGeminiOrLocal(transcription);

//       // 3. Validar
//       final validatedData = _validateStructuredData(
//         analysisResult,
//         transcription,
//       );

//       // 4. Limpiar
//       _cleanupAudioFile(finalAudioPath);

//       return {
//         'success': true,
//         'transcription': transcription,
//         'data': validatedData,
//         'message': validatedData['user_message'] ?? 'Comando procesado',
//       };
//     } catch (e) {
//       print('❌ Error general: $e');
//       if (_currentAudioPath != null) {
//         _cleanupAudioFile(_currentAudioPath!);
//       }
//       return {
//         'success': false,
//         'error': e.toString(),
//         'message': 'Error inesperado',
//       };
//     }
//   }

//   // ==================== ANÁLISIS CON GEMINI (VERSIÓN CORRECTA) ====================
//   Future<Map<String, dynamic>> _analyzeWithGeminiOrLocal(String text) async {
//     // Primero intentar con Gemini si hay API key
//     if (_geminiApiKey.isNotEmpty && _geminiApiKey != 'TU_API_KEY_AQUI') {
//       try {
//         return await _analyzeWithGemini(text);
//       } catch (e) {
//         print('⚠️ Gemini falló: $e, usando local');
//         return _analyzeLocally(text);
//       }
//     } else {
//       print('ℹ️ Sin API key, usando análisis local');
//       return _analyzeLocally(text);
//     }
//   }

//   Future<Map<String, dynamic>> _analyzeWithGemini(String text) async {
//     print('🚀 Usando Gemini API...');

//     // URL CORRECTA para Gemini
//     final url =
//         '$_geminiBaseUrl/models/$_chatModel:generateContent?key=$_geminiApiKey';
//     print('🔗 URL: ${url.replaceAll(_geminiApiKey, '***')}');

//     // Prompt optimizado
//     final prompt = '''Analiza este comando financiero español: "$text"

// Devuelve SOLO JSON con:
// {
//   "type": "gasto|ingreso|compartido|prestamo|pago_persona|otro",
//   "monto": numero_o_null,
//   "titulo": "texto",
//   "categoria": "comida|transporte|hogar|entretenimiento|servicios|compras|salud|ingreso|otros",
//   "persona": "nombre_o_null",
//   "compartido": true/false,
//   "es_prestamo": true/false
// }''';

//     try {
//       final response = await http
//           .post(
//             Uri.parse(url),
//             headers: {'Content-Type': 'application/json'},
//             body: jsonEncode({
//               'contents': [
//                 {
//                   'parts': [
//                     {'text': prompt},
//                   ],
//                 },
//               ],
//               'generationConfig': {'temperature': 0.1, 'maxOutputTokens': 200},
//             }),
//           )
//           .timeout(const Duration(seconds: 10));

//       print('📡 Status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         // Extraer texto de respuesta
//         String responseText;
//         try {
//           responseText = data['candidates'][0]['content']['parts'][0]['text'];
//         } catch (e) {
//           print('❌ Estructura inesperada: $data');
//           throw Exception('Respuesta Gemini inválida');
//         }

//         print('📨 Respuesta: $responseText');

//         // Extraer JSON
//         final jsonMatch = RegExp(
//           r'\{.*\}',
//           dotAll: true,
//         ).firstMatch(responseText);
//         if (jsonMatch == null) {
//           throw Exception('No se encontró JSON en respuesta');
//         }

//         final jsonResult =
//             jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;

//         // Convertir a nuestro formato
//         return {
//           'transaction_type': _mapGeminiType(jsonResult['type']),
//           'amount': jsonResult['monto'],
//           'title': jsonResult['titulo'] ?? 'Transacción',
//           'category': jsonResult['categoria'] ?? 'otros',
//           'target_person': jsonResult['persona'],
//           'is_shared': jsonResult['compartido'] ?? false,
//           'is_loan': jsonResult['es_prestamo'] ?? false,
//           'confidence': 0.9,
//           'user_message': 'Analizado con IA',
//         };
//       } else {
//         print('❌ Error ${response.statusCode}: ${response.body}');
//         throw Exception('Error Gemini: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('❌ Error Gemini: $e');
//       rethrow;
//     }
//   }

//   String _mapGeminiType(String? geminiType) {
//     const map = {
//       'gasto': 'personal_expense',
//       'ingreso': 'income',
//       'compartido': 'shared_expenses',
//       'prestamo': 'loan',
//       'pago_persona': 'payment_to_person',
//       'otro': 'other',
//     };
//     return map[geminiType] ?? 'personal_expense';
//   }

//   // ==================== ANÁLISIS LOCAL (BACKUP) ====================
//   Map<String, dynamic> _analyzeLocally(String text) {
//     print('🔧 Análisis local para: "$text"');

//     final lower = text.toLowerCase();

//     // Extraer monto
//     double? amount;
//     final amountMatch = RegExp(r'(\d+([.,]\d{1,2})?)').firstMatch(text);
//     if (amountMatch != null) {
//       amount = double.tryParse(amountMatch.group(0)!.replaceAll(',', '.'));
//     }

//     // Detectar tipo
//     String type = 'personal_expense';
//     if (lower.contains('recib') ||
//         lower.contains('ingreso') ||
//         lower.contains('gané')) {
//       type = 'income';
//     } else if (lower.contains('prest') ||
//         lower.contains('debe') ||
//         lower.contains('préstamo')) {
//       type = 'loan';
//     } else if (lower.contains('compart') ||
//         lower.contains('entre todos') ||
//         lower.contains('dividir')) {
//       type = 'shared_expenses';
//     } else if (lower.contains('pag') && lower.contains(' a ')) {
//       type = 'payment_to_person';
//     }

//     // Extraer persona
//     String? person;
//     final personMatch = RegExp(
//       r'\b(a|para|de|con)\s+([A-ZÁÉÍÓÚÑ][a-záéíóúñ]+)',
//     ).firstMatch(text);
//     if (personMatch != null) {
//       person = personMatch.group(2);
//     }

//     // Categoría
//     String category = 'otros';
//     if (lower.contains('comida') ||
//         lower.contains('cena') ||
//         lower.contains('almuerzo')) {
//       category = 'comida';
//     } else if (lower.contains('gasolina') || lower.contains('transporte')) {
//       category = 'transporte';
//     } else if (lower.contains('luz') ||
//         lower.contains('agua') ||
//         lower.contains('servicio')) {
//       category = 'servicios';
//     } else if (lower.contains('ropa') || lower.contains('zapatos')) {
//       category = 'compras';
//     }

//     return {
//       'transaction_type': type,
//       'amount': amount,
//       'title': person != null ? 'Con $person' : category,
//       'category': category,
//       'target_person': person,
//       'is_shared': type == 'shared_expenses',
//       'is_loan': type == 'loan',
//       'is_payment_to_person': type == 'payment_to_person',
//       'confidence': amount != null ? 0.8 : 0.6,
//       'user_message':
//           amount != null ? 'Registrado: \$$amount' : 'Transacción registrada',
//     };
//   }

//   // ==================== TRANSCRIPCIÓN CON GROQ ====================
//   Future<String> _transcribeWithGroq(String audioPath) async {
//     try {
//       final groqApiKey =
//           'api jey xd';

//       final file = File(audioPath);
//       final bytes = await file.readAsBytes();

//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('https://api.groq.com/openai/v1/audio/transcriptions'),
//       );

//       request.headers['Authorization'] = 'Bearer $groqApiKey';
//       request.files.add(
//         http.MultipartFile.fromBytes('file', bytes, filename: 'audio.wav'),
//       );

//       request.fields.addAll({
//         'model': 'whisper-large-v3',
//         'language': 'es',
//         'response_format': 'json',
//       });

//       final response = await request.send().timeout(
//         const Duration(seconds: 20),
//       );
//       final body = await response.stream.bytesToString();

//       if (response.statusCode == 200) {
//         final data = jsonDecode(body);
//         return data['text']?.toString().trim() ?? '';
//       } else {
//         print('⚠️ Transcripción error: ${response.statusCode}');
//         return '';
//       }
//     } catch (e) {
//       print('⚠️ Error transcripción: $e');
//       return '';
//     }
//   }

//   // ==================== VALIDACIÓN ====================
//   Map<String, dynamic> _validateStructuredData(
//     Map<String, dynamic> data,
//     String text,
//   ) {
//     // Validaciones básicas
//     final type = data['transaction_type'] ?? 'personal_expense';
//     final amount = data['amount'];
//     final person = data['target_person'];

//     return {
//       'transaction_type': type,
//       'amount': amount,
//       'title': data['title'] ?? 'Transacción',
//       'description': text,
//       'category': data['category'] ?? 'otros',
//       'target_person': person,
//       'is_shared': data['is_shared'] ?? false,
//       'is_loan': data['is_loan'] ?? false,
//       'is_payment_to_person': data['is_payment_to_person'] ?? false,
//       'confidence': (data['confidence'] as num?)?.toDouble() ?? 0.5,
//       'user_message':
//           data['user_message'] ?? _generateUserMessage(type, amount, person),
//       'date': DateTime.now().toIso8601String().split('T')[0],
//       'created_at': DateTime.now().toIso8601String(),
//     };
//   }

//   String _generateUserMessage(String type, double? amount, String? person) {
//     final typeNames = {
//       'personal_expense': 'Gasto',
//       'income': 'Ingreso',
//       'shared_expenses': 'Gasto compartido',
//       'loan': 'Préstamo',
//       'payment_to_person': 'Pago',
//     };

//     final typeName = typeNames[type] ?? 'Transacción';

//     if (amount != null && person != null) {
//       return '✅ $typeName de \$$amount con $person';
//     } else if (amount != null) {
//       return '✅ $typeName de \$$amount registrado';
//     } else {
//       return '✅ $typeName registrado';
//     }
//   }

//   // ==================== UTILIDADES ====================
//   void _cleanupAudioFile(String path) {
//     try {
//       final file = File(path);
//       if (file.existsSync()) {
//         file.deleteSync();
//       }
//     } catch (e) {
//       print('⚠️ Error limpiando audio: $e');
//     }
//   }

//   Future<void> cancelRecording() async {
//     if (_isRecording) {
//       await _audioRecorder.stop();
//       _isRecording = false;
//       if (_currentAudioPath != null) {
//         _cleanupAudioFile(_currentAudioPath!);
//       }
//     }
//   }

//   Future<void> dispose() async {
//     await cancelRecording();
//     await _audioRecorder.dispose();
//   }

//   bool get isRecording => _isRecording;
// }
