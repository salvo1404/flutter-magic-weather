import 'package:flutter/material.dart';
import 'package:MagicWeather/utils/themes.dart';

import 'dart:math';

class AppModel {
  ThemeData _theme = Themes.getTheme(Themes.DARK_THEME_CODE);
  int themeCode = Themes.DARK_THEME_CODE;

  ThemeData get theme => _theme;

  void setThemeLight() {
    themeCode = Themes.LIGHT_THEME_CODE;

    // notifyListeners();
  }

  /**
   * Example of async
   */
  Future<double> getRandomValue() async {
    var random = Random(2);
    await Future.delayed(Duration(seconds: 1));
    return random.nextDouble();
  }

  /**
   * Example of Stream
   */
  Stream<double> getRandomValuesStream() async* {
    var random = Random(2);
    
    await Future.delayed(Duration(seconds: 5));
    yield random.nextDouble();
  }
}