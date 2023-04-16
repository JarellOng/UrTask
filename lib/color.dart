 import 'package:flutter/material.dart';

const MaterialColor primary = MaterialColor(_primaryPrimaryValue, <int, Color>{
  50: Color(0xFFFFF0F0),
  100: Color(0xFFFED8D8),
  200: Color(0xFFFEBFBF),
  300: Color(0xFFFDA5A5),
  400: Color(0xFFFC9191),
  500: Color(_primaryPrimaryValue),
  600: Color(0xFFFC7676),
  700: Color(0xFFFB6B6B),
  800: Color(0xFFFB6161),
  900: Color(0xFFFA4E4E),
});
 const int _primaryPrimaryValue = 0xFFFC7E7E;

 const MaterialColor secondary = MaterialColor(_secondaryAccentValue, <int, Color>{
  500: Color(_secondaryAccentValue),
});
 const int _secondaryAccentValue = 0xFFFFF2F2;