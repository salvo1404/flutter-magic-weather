import 'package:flutter/material.dart';
import 'package:MagicWeather/screens/settings_screen.dart';
import 'package:MagicWeather/screens/weather_screen.dart';

class Routes {

  static final mainRoute = <String, WidgetBuilder>{
    '/home': (context) => WeatherScreen(),
    '/settings': (context) => SettingsScreen(),
  };
}
