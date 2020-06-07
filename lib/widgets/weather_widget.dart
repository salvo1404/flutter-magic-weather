import 'package:flutter/material.dart';
import 'package:MagicWeather/models/weather_model.dart';
import 'package:MagicWeather/utils/converters.dart';
import 'package:MagicWeather/widgets/forecast_horizontal_widget.dart';

class WeatherWidget extends StatelessWidget {
  final Weather weather;

  WeatherWidget({this.weather}) : assert(weather != null);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            this.weather.cityName,
            style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 5,
                color: Colors.white,
                fontSize: 25),
          ),
          SizedBox(
            height: 20,
          ),
          Text(
            this.weather.description.toUpperCase(),
            style: TextStyle(
                fontWeight: FontWeight.w500,
                letterSpacing: 5,
                fontSize: 15,
                color: Colors.white),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Icon(
                this.weather.getIconData(),
                color: Colors.white,
                size: 70,
              ),
              // SizedBox(
              //   height: 20,
              // ),
              Text(
                '${this.weather.temperature.as(TemperatureUnit.celsius).round()}°',
                style: TextStyle(
                    fontSize: 100,
                    fontWeight: FontWeight.w100,
                    color: Colors.white,
                ),
              ),
            ],
          ),
          
          // WeatherSwipePager(weather: weather),
          Padding(
            padding: EdgeInsets.all(10),
          ),
          Divider(
              color:
                  Colors.white.withAlpha(50),
            ),
          ForecastHorizontal(weathers: weather.forecast),
          Divider(
              color:
                  Colors.white.withAlpha(50),
            ),
          Padding(
            padding: EdgeInsets.all(10),
          ),
        ],
      ),
    );
  }
}
