import 'package:flutter/material.dart';
import 'package:walleta/screens/auth/screens/auth.dart';
import 'package:walleta/screens/home/home.dart';

Map<String, Widget Function(BuildContext)> routes = {
  '/auth': (_) => const AuthScreen(),
  '/home': (_) => const Home(),
};
