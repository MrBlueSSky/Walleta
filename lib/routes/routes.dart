import 'package:flutter/material.dart';
import 'package:walleta/screens/auth/screens/auth.dart';

Map<String, Widget Function(BuildContext)> routes = {
  '/auth': (_) => const AuthScreen(),
};
