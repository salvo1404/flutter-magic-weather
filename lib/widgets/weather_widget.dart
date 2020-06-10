import 'package:flutter/material.dart';
import 'package:MagicWeather/models/weather_model.dart';
import 'package:MagicWeather/models/app_model.dart';
import 'package:MagicWeather/utils/converters.dart';
import 'package:intl/intl.dart';
import 'package:MagicWeather/widgets/forecast_horizontal_widget.dart';
import 'package:MagicWeather/widgets/value_tile.dart';
import 'package:provider/provider.dart';

class WeatherWidget extends StatelessWidget {
  final Weather weather;

  WeatherWidget({this.weather}) : assert(weather != null);

  @override
  Widget build(BuildContext context) {
    List<int> days = [0,1,2,3,4,5];
    var today = new DateTime.now();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(20),
        ),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              this.weather.getIconData(),
              color: Colors.white,
              size: 70,
            ),
            SizedBox(
              width: 40,
            ),
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

        ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: days.length,
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(top: 0, bottom: 0),
          itemBuilder: (context, index) {
            final day = days[index];

            // Hack to remove ExpansiontTile divider colours
            final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
    
            return Column(
              children: <Widget>[
                
                Theme(
                  data: theme,
                  child: ExpansionTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: 120,
                          child: Text(
                            DateFormat('EEEE').format(today.add(new Duration(days: day))),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                                color: Colors.white,
                                fontSize: 15,),
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: Text(
                            (index==0) ? 'TODAY' : '',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                letterSpacing: 1,
                                color: Colors.white,
                                fontSize: 15,),
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: Icon(
                            weather.forecast[index].getIconData(),
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                        
                      ],
                    ),
                    initiallyExpanded: index==0,
                    trailing: Text(
                      '${weather.forecast[index].temperature.as(TemperatureUnit.celsius).round()}°',
                      style: TextStyle(
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                      ),
                    ),
                    children: <Widget>[
                      Divider(
                        color:
                            Colors.white,
                      ),
                      ForecastHorizontal(weathers: _filterForecastByDay(weather.forecast, day)),
                      if(index != days.length-1) // Skip last
                      Divider(
                        color:
                            Colors.white,
                      ),
                    ],
                  ),
                ),

              ],
            );
          }
        ),
        
        Divider(
          color:
              Colors.white,
        ),
        Padding(
          padding: EdgeInsets.all(10),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ValueTile("wind speed", '${this.weather.windSpeed} m/s'),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Center(
                  child: Container(
                width: 1,
                height: 30,
                color: Provider.of<AppModel>(context)
                    .theme
                    .accentColor
                    .withAlpha(50),
              )),
            ),
            ValueTile(
                "sunrise",
                DateFormat('h:m a').format(DateTime.fromMillisecondsSinceEpoch(
                    this.weather.sunrise * 1000))),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Center(
                  child: Container(
                width: 1,
                height: 30,
                color: Provider.of<AppModel>(context)
                    .theme
                    .accentColor
                    .withAlpha(50),
              )),
            ),
            ValueTile(
                "sunset",
                DateFormat('h:m a').format(DateTime.fromMillisecondsSinceEpoch(
                    this.weather.sunset * 1000))),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Center(
                  child: Container(
                width: 1,
                height: 30,
                color: Provider.of<AppModel>(context)
                    .theme
                    .accentColor
                    .withAlpha(50),
              )),
            ),
            ValueTile("humidity", '${this.weather.humidity}%'),
          ]
        ),
        Padding(
          padding: EdgeInsets.all(10),
        ),
        

        Padding(
          padding: EdgeInsets.all(0),
        ),
        
      ],
    );
  }

  List<Weather> _filterForecastByDay(List<Weather> weathers, int day) {
      TimeOfDay timeOfDay = TimeOfDay.now();
      var offsetMidnight = DateTime.now().add(new Duration(days: day-1, hours: 23-timeOfDay.hour, minutes: 59-timeOfDay.minute));

      var dayWeathers = weathers.where((item) {
        var forecastDate = new DateTime.fromMillisecondsSinceEpoch(item.time * 1000);

        return forecastDate.isAfter(offsetMidnight);
    }).toList();

    return dayWeathers;
  }
}
