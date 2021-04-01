import 'package:magic_weather/utils/weather_api_client.dart';
import 'package:magic_weather/models/weather_model.dart';
import 'package:meta/meta.dart';

class WeatherRepository {
  final WeatherApiClient weatherApiClient;
  WeatherRepository({@required this.weatherApiClient})
      : assert(weatherApiClient != null);

  Future<Weather> getWeather(String cityName,
      {double latitude, double longitude}) async {
    if (cityName == '') {
      cityName = await weatherApiClient.getCityNameFromLocation(
          latitude: latitude, longitude: longitude);
    }
    var weather = await weatherApiClient.getWeatherData(cityName);
    var forecast = await weatherApiClient.getForecast(cityName);
    weather.forecast = forecast;
    return weather;
  }
}
