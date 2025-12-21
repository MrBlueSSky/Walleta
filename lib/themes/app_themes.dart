import 'package:flutter/material.dart';
import 'package:walleta/themes/app_colors.dart';

class AppThemes {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    indicatorColor: Colors.white,
    scaffoldBackgroundColor: Color(0xFFF2F2F7),

    primaryColor: Color(0xFFFA243C), //!Ver
    secondaryHeaderColor: Color(0xFFFF2D92), // Apple Music pink accent

    cardColor: Color(0xFFD9D9D9),
    shadowColor: Colors.black.withOpacity(0.04),
    textTheme: const TextTheme(
      labelSmall: TextStyle(color: Color(0xFF373737)),
      bodyLarge: TextStyle(color: Color(0xFF000000)),
    ),

    iconTheme: const IconThemeData(color: AppColors.textBlack),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: Color(0xFFFA243C), // Apple Music red
      ),
    ),
  );

  //!Por defecto la app esta usando este
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    indicatorColor: Colors.black,
    scaffoldBackgroundColor: Color(0xFF1C1C1E),

    primaryColor: Color(0xFFFA243C), //!Ver
    secondaryHeaderColor: Color(0xFFFF2D92), // Apple Music pink accent

    cardColor: Color(0xFF2C2C2E),
    shadowColor: Colors.white.withOpacity(0.04),
    textTheme: const TextTheme(
      labelSmall: TextStyle(color: Color(0xFF8E8E93)),
      bodyLarge: TextStyle(color: Color(0xFFFFFFFF)),
    ),

    iconTheme: const IconThemeData(color: Color(0xFFFFFFFF)),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: Color(0xFFFA243C), // Apple Music red
      ),
    ),
  );
}
