import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:walleta/app.dart';
import 'package:walleta/simple_bloc_observer.dart';
import 'firebase_options.dart';
import 'package:walleta/repository/authentication/authentication_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      print("Platform: ${kIsWeb ? 'Web' : 'Mobile'}");

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      print("Firebase inicializado correctamente");
    }
  } catch (e, stackTrace) {
    print("Error durante la inicialización: $e");
    print("StackTrace: $stackTrace");
  }

  EquatableConfig.stringify = kDebugMode;
  Bloc.observer = SimpleBlocObserver();
  runApp(App(authenticationRepository: AuthenticationRepository()));
}
