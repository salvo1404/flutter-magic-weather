import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:MagicWeather/models/app_model.dart';
import 'package:MagicWeather/state/weather_state.dart';
import 'package:MagicWeather/routes/routes.dart';
import 'package:MagicWeather/screens/weather_screen.dart';
import 'package:MagicWeather/repository/weather_repository.dart';
import 'package:MagicWeather/utils/weather_api_client.dart';
import 'package:http/http.dart' as http;
import 'package:MagicWeather/utils/api_keys.dart';

void main() {
  final WeatherRepository weatherRepository = WeatherRepository(
      weatherApiClient: WeatherApiClient(
          httpClient: http.Client(),
          apiKey: ApiKey.OPEN_WEATHER_MAP
      )
  );

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => AppModel()),
        ChangeNotifierProvider(create: (context) => WeatherModel(
          weatherRepository: weatherRepository
        )),
      ],
      child: WeatherApp(),
    ),
  );
}

class WeatherApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final appModel = Provider.of<AppModel>(context);
    return MaterialApp(
      title: 'Magic Weather App',
      theme: appModel.theme,
      home: WeatherScreen(),
      routes: Routes.mainRoute,
    );
  }
}