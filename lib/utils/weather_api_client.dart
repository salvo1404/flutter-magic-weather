import 'dart:convert';
import 'package:MagicWeather/utils/http_exception.dart';
import 'package:MagicWeather/models/weather_model.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper around the open weather map api
/// https://openweathermap.org/current
class WeatherApiClient {
  static const baseUrl = 'api.openweathermap.org';
  final apiKey;
  final http.Client httpClient;

  WeatherApiClient({@required this.httpClient, this.apiKey})
      : assert(httpClient != null),
        assert(apiKey != null);

  Future<String> getCityNameFromLocation(
      {double latitude, double longitude}) async {
    if (latitude == 0 || longitude == 0) {
      throw HTTPException(400, "Unable to fetch weather data. Select location");
    }

    final Uri url = Uri.https(baseUrl, "/data/2.5/weather", {
      "lat": latitude.toString(),
      "lon": longitude.toString(),
      "appid": apiKey
    });

    print('fetching $url');

    final res = await this.httpClient.get(url);
    if (res.statusCode != 200) {
      throw HTTPException(res.statusCode, "unable to fetch weather data");
    }
    final weatherJson = json.decode(res.body);
    _saveStringSharedPreferences('city', weatherJson['name']);
    return weatherJson['name'];
  }

  Future<Weather> getWeatherData(String cityName) async {
    final Uri url = Uri.https(
        baseUrl, "/data/2.5/weather", {"q": cityName, "appid": apiKey});

    print('fetching $url');
    final res = await this.httpClient.get(url);
    if (res.statusCode != 200) {
      throw HTTPException(res.statusCode, "unable to fetch weather data");
    }
    _saveStringSharedPreferences('weather', res.body);
    final weatherJson = json.decode(res.body);
    return Weather.fromJson(weatherJson);
  }

  Future<List<Weather>> getForecast(String cityName) async {
    final Uri url = Uri.https(
        baseUrl, "/data/2.5/forecast", {"q": cityName, "appid": apiKey});

    // final url = '$baseUrl/data/2.5/forecast?q=$cityName&appid=$apiKey';
    print('fetching $url');
    final res = await this.httpClient.get(url);
    if (res.statusCode != 200) {
      throw HTTPException(res.statusCode, "unable to fetch weather data");
    }
    _saveStringSharedPreferences('forecast', res.body);
    final forecastJson = json.decode(res.body);
    List<Weather> weathers = Weather.fromForecastJson(forecastJson);
    return weathers;
  }

  _saveStringSharedPreferences(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString(key, value);
    print('Saved $key: $value');
  }
}
