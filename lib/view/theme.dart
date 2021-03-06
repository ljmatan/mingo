import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mingo/services/device_info/device_info.dart';

/// Global theme parameters
abstract class MinGOTheme {
  static const _primaryColor = Color(0xff242C35);

  static const buttonGradient = LinearGradient(
    colors: [
      Color(0xff28E2D7),
      Color(0xff00A1F1),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomCenter,
    transform: GradientRotation(.66),
  );

  static double get screenWidth => WidgetsBinding.instance.window.physicalSize.width / WidgetsBinding.instance.window.devicePixelRatio;

  static final data = ThemeData(
    useMaterial3: !kIsWeb && DeviceInfo.androidApiVersion != null && DeviceInfo.androidApiVersion! > 30,
    scaffoldBackgroundColor: _primaryColor,
    primaryColor: _primaryColor,
    fontFamily: 'Inter',
    textTheme: TextTheme(
      bodyText1: TextStyle(
        fontWeight: FontWeight.w400,
        color: Colors.white,
        fontSize: screenWidth < 1000 ? 16 : 14,
      ),
      bodyText2: TextStyle(
        fontWeight: FontWeight.w400,
        color: _primaryColor,
        fontSize: screenWidth < 1000 ? 16 : 14,
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      elevation: 1,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.white,
      contentTextStyle: TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.black,
        fontSize: 18,
      ),
    ),
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Color(0xff242C35),
        systemNavigationBarColor: Color(0xff242C35),
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    ),
  );
}
