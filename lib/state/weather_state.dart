import "package:MagicWeather/models/weather.dart";
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:MagicWeather/utils/http_exception.dart';
import 'package:MagicWeather/repository/weather_repository.dart';

class WeatherStateModel with ChangeNotifier {
  String city = '';

  WeatherState weatherState = WeatherEmpty();

  final WeatherRepository weatherRepository;

  WeatherStateModel({@required this.weatherRepository})
      : assert(weatherRepository != null);

  void setCity(String city) {
    this.city = city;
  }

  void mapFetchWeatherToState() async {
    try {
        final Weather weather = await weatherRepository.getWeather(
            this.city,
            latitude: 0.0,
            longitude: 0.0);
        this.weatherState = WeatherLoaded(weather: weather);
      } catch (exception) {
        print(exception);
        if (exception is HTTPException) {
          this.weatherState = WeatherError(errorCode: exception.code);
        } else {
          this.weatherState = WeatherError(errorCode: 500);
        }
    }

    notifyListeners();
  }
}

class WeatherState extends Equatable {
  WeatherState([List props = const []]) : super(props);
}

class WeatherEmpty extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final Weather weather;

  WeatherLoaded({@required this.weather})
      : assert(weather != null),
        super([weather]);
}

class WeatherError extends WeatherState {
  final int errorCode;

  WeatherError({@required this.errorCode})
      : assert(errorCode != null),
        super([errorCode]);
}