import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:magic_weather/models/app_model.dart';
import 'package:magic_weather/models/weather_model.dart';
import 'package:magic_weather/routes/routes.dart';
import 'package:magic_weather/screens/weather_screen.dart';
import 'package:magic_weather/repository/weather_repository.dart';
import 'package:magic_weather/utils/weather_api_client.dart';
import 'package:http/http.dart' as http;
import 'package:magic_weather/utils/api_keys.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  final WeatherRepository weatherRepository = WeatherRepository(
      weatherApiClient: WeatherApiClient(
          httpClient: http.Client(), apiKey: ApiKey.OPEN_WEATHER_MAP));

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (context) => AppModel()),
        ChangeNotifierProvider(
            create: (context) =>
                WeatherModel(weatherRepository: weatherRepository)),
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
