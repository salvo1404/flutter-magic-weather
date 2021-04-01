import 'package:flutter/material.dart';
import 'package:magic_weather/screens/settings_screen.dart';
import 'package:magic_weather/screens/weather_screen.dart';

class Routes {
  static final mainRoute = <String, WidgetBuilder>{
    '/home': (context) => WeatherScreen(),
    '/settings': (context) => SettingsScreen(),
  };
}
