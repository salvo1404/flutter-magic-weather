import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:MagicWeather/utils/weather_icons.dart';
import 'package:MagicWeather/utils/converters.dart';
import 'package:MagicWeather/utils/http_exception.dart';
import 'package:MagicWeather/repository/weather_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherModel with ChangeNotifier {
  String city = '';

  double lat = 0.0;
  double long = 0.0;

  String weatherState = 'empty';

  int errorCode = 0;

  Weather weather;

  final WeatherRepository weatherRepository;

  WeatherModel({@required this.weatherRepository})
      : assert(weatherRepository != null);

  void setCity(String city) async {
    this.city = city;

    if (city == '') {
      this.weatherState = 'empty';
    }

    // notifyListeners();
  }

  void setLocation(double lat, double long) async {
    this.lat = lat;
    this.long = long;
  }

  void refreshWeather(int delay) async {
    await Future.delayed(Duration(seconds: delay));
    print('Pull fresh weather data');

    if (this.city == '' && (this.lat == 0.0 && this.long == 0.0)) {
      return;
    }

    setWeatherFromLocation();
  }

  void setWeatherFromLocation() async {
    print('Trying to set weather From Location');

    try {
      this.weather = await weatherRepository.getWeather(this.city,
          latitude: this.lat, longitude: this.long);
      this.weatherState = 'cached';
    } catch (exception) {
      print(exception);
      if (exception is HTTPException) {
        this.weatherState = 'error';
        this.errorCode = exception.code;
      } else {
        this.weatherState = 'error';
        this.errorCode = 500;
      }
    }

    notifyListeners();
  }

  void setWeatherFromCache() async {
    final prefs = await SharedPreferences.getInstance();

    final weatherJson = prefs.getString('weather') ?? '';
    print('Trying to load Weather from cache...');

    if (weatherJson == '') {
      return;
    }

    var weatherJsonString = json.decode(weatherJson);
    this.weather = Weather.fromJson(weatherJsonString);

    final forecastJson = prefs.getString('forecast') ?? '';
    print('Load Forecast: $forecastJson');
    List<Weather> weathers =
        Weather.fromForecastJson(json.decode(forecastJson));
    this.weather.forecast = weathers;

    this.city = this.weather.cityName;
    this.weatherState = 'cached';

    print('Loaded Weather from cache: $weatherJson');
    notifyListeners();
  }
}

class Weather {
  int id;
  int time;
  int sunrise;
  int sunset;
  int humidity;

  String description;
  String iconCode;
  String main;
  String cityName;

  double windSpeed;

  Temperature temperature;
  Temperature maxTemperature;
  Temperature minTemperature;

  List<Weather> forecast;

  Weather(
      {this.id,
      this.time,
      this.sunrise,
      this.sunset,
      this.humidity,
      this.description,
      this.iconCode,
      this.main,
      this.cityName,
      this.windSpeed,
      this.temperature,
      this.maxTemperature,
      this.minTemperature,
      this.forecast});

  static Weather fromJson(Map<String, dynamic> json) {
    final weather = json['weather'][0];
    return Weather(
      id: weather['id'],
      time: json['dt'],
      description: weather['description'],
      iconCode: weather['icon'],
      main: weather['main'],
      cityName: json['name'],
      temperature: Temperature(intToDouble(json['main']['temp'])),
      maxTemperature: Temperature(intToDouble(json['main']['temp_max'])),
      minTemperature: Temperature(intToDouble(json['main']['temp_min'])),
      sunrise: json['sys']['sunrise'],
      sunset: json['sys']['sunset'],
      humidity: json['main']['humidity'],
      windSpeed: intToDouble(json['wind']['speed']),
    );
  }

  static List<Weather> fromForecastJson(Map<String, dynamic> json) {
    final weathers = List<Weather>(); //Deprecated
    for (final item in json['list']) {
      weathers.add(Weather(
          time: item['dt'],
          temperature: Temperature(intToDouble(
            item['main']['temp'],
          )),
          iconCode: item['weather'][0]['icon']));
    }
    return weathers;
  }

  IconData getIconData() {
    switch (this.iconCode) {
      case '01d':
        return WeatherIcons.clear_day;
      case '01n':
        return WeatherIcons.clear_night;
      case '02d':
        return WeatherIcons.few_clouds_day;
      case '02n':
        return WeatherIcons.few_clouds_day;
      case '03d':
      case '04d':
        return WeatherIcons.clouds_day;
      case '03n':
      case '04n':
        return WeatherIcons.clear_night;
      case '09d':
        return WeatherIcons.shower_rain_day;
      case '09n':
        return WeatherIcons.shower_rain_night;
      case '10d':
        return WeatherIcons.rain_day;
      case '10n':
        return WeatherIcons.rain_night;
      case '11d':
        return WeatherIcons.thunder_storm_day;
      case '11n':
        return WeatherIcons.thunder_storm_night;
      case '13d':
        return WeatherIcons.snow_day;
      case '13n':
        return WeatherIcons.snow_night;
      case '50d':
        return WeatherIcons.mist_day;
      case '50n':
        return WeatherIcons.mist_night;
      default:
        return WeatherIcons.clear_day;
    }
  }
}
