import 'package:flutter/material.dart';
import 'package:walleta/themes/app_themes.dart';

class ThemeProvider extends ChangeNotifier {
  bool isDarkMode = true;

  ThemeData get theme =>
      isDarkMode ? AppThemes.darkTheme : AppThemes.lightTheme;

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }
}
