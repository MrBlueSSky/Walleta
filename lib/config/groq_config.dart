import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class GroqConfig {
  static bool _isInitialized = false;
  static String? _cachedApiKey;

  // Inicializar configuración
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Cargar variables de entorno
      await _loadEnv();

      // Obtener y validar API key
      _cachedApiKey = _extractApiKey();
      _validateApiKey(_cachedApiKey);

      _isInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('Error inicializando GroqConfig: $e');
      }
      rethrow;
    }
  }

  static Future<void> _loadEnv() async {
    try {
      // Intentar cargar desde ubicaciones comunes
      await dotenv.load(fileName: ".env");
    } catch (_) {
      print('🚯🚯🚯🚯🚯🚯🚯🚯🚯🚯🚯🚯🚯🚯🚯🚯🚯');
      try {
        await dotenv.load(fileName: "assets/.env");
      } catch (_) {
        await dotenv.load();
      }
    }
  }

  static String _extractApiKey() {
    return dotenv.env['GROQ_API_KEY'] ??
        dotenv.env['GROQ_APIKEY'] ??
        dotenv.env['GROQAPIKEY'] ??
        dotenv.env['API_KEY'] ??
        '';
  }

  static void _validateApiKey(String? key) {
    if (key == null || key.isEmpty) {
      throw Exception(
        'GROQ_API_KEY no configurada. '
        'Agrega GROQ_API_KEY=tu_clave_real en tu archivo .env\n'
        'Obtén una clave en: https://console.groq.com',
      );
    }
  }

  static String get apiKey {
    _assertInitialized();

    final key = _cachedApiKey;
    if (key == null || key.isEmpty) {
      throw Exception('API Key no disponible. Verifica tu configuración.');
    }

    return key;
  }

  static String get baseUrl {
    _assertInitialized();
    return dotenv.env['GROQ_BASE_URL']!;
  }

  static String get transcriptionModel {
    _assertInitialized();
    return dotenv.env['TRANSCRIPTION_MODEL']!;
  }

  static String get chatModel {
    _assertInitialized();
    return dotenv.env['CHAT_MODEL']!;
  }

  static void _assertInitialized() {
    if (!_isInitialized) {
      throw Exception(
        'GroqConfig no inicializado. Llama a initialize() primero.',
      );
    }
  }
}
