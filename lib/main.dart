import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:walleta/app.dart';
import 'package:walleta/simple_bloc_observer.dart';
import 'firebase_options.dart';
import 'package:walleta/repository/authentication/authentication_repository.dart';
import 'package:walleta/config/groq_config.dart'; // Asegúrate de importar

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await GroqConfig.initialize();

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        print('✅ Firebase inicializado correctamente');
      } else {
        print('Firebase ya estaba inicializado');
      }
    } catch (e) {
      print('⚠️ Error inicializando Firebase: $e');
    }
  } catch (e) {
    print('\n❌ ERROR DURANTE LA INICIALIZACIÓN:');
  }

  EquatableConfig.stringify = kDebugMode;
  Bloc.observer = SimpleBlocObserver();

  final authenticationRepository = AuthenticationRepository();

  runApp(App(authenticationRepository: authenticationRepository));
}
