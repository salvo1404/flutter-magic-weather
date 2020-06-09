import 'package:flutter/material.dart';
import 'package:MagicWeather/models/weather_model.dart';
import 'package:MagicWeather/utils/converters.dart';
import 'package:intl/intl.dart';
import 'package:MagicWeather/widgets/forecast_horizontal_widget.dart';

class WeatherWidget extends StatelessWidget {
  final Weather weather;

  WeatherWidget({this.weather}) : assert(weather != null);

  @override
  Widget build(BuildContext context) {
    List<int> days = [0,1,2,3,4];
    var today = new DateTime.now();
    var expanded = false;
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
            padding: EdgeInsets.only(top: 0, bottom: 0),
            itemBuilder: (context, index) {
              final day = days[index];
              if(index == 0) {
                expanded = true;
              } else {
                expanded = false;
              }
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
                          Text(
                            DateFormat('EEEE').format(today.add(new Duration(days: day))),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3,
                                color: Colors.white,
                                fontSize: 15,),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                        ],
                      ),
                      initiallyExpanded: expanded,
                      trailing: SizedBox(
                          width: 5,
                        ),
                      children: <Widget>[
                        Divider(
                          color:
                              Colors.white,
                        ),
                        ForecastHorizontal(weathers: weather.forecast),
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
          
          Padding(
            padding: EdgeInsets.all(0),
          ),
        ],
      ),
    );
  }
}
