import 'package:flutter/material.dart';
import 'package:MagicWeather/models/weather_model.dart';
import 'package:MagicWeather/utils/converters.dart';
import 'package:intl/intl.dart';
import 'package:MagicWeather/widgets/forecast_horizontal_widget.dart';

class WeatherWidget extends StatefulWidget {
  final Weather weather;
  WeatherWidget({this.weather}) : assert(weather != null);

  @override
  _WeatherWidget createState() { return _WeatherWidget(); }
}

class _WeatherWidget extends State<WeatherWidget> {

  // selected's value = 0. For default first item is open.
  int selected = 0; //attention

  @override
  Widget build(BuildContext context) {
    List<int> days = [0,1,2,4,5];
    var today = new DateTime.now();
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            widget.weather.cityName,
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
            widget.weather.description.toUpperCase(),
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
                widget.weather.getIconData(),
                color: Colors.white,
                size: 70,
              ),
              SizedBox(
                width: 40,
              ),
              Text(
                '${widget.weather.temperature.as(TemperatureUnit.celsius).round()}°',
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
            padding: EdgeInsets.all(0),
          ),
          
          
          ListView.builder(
            key: Key('builder ${selected.toString()}'),
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: days.length,
            padding: EdgeInsets.only(top: 10, bottom: 10),
            itemBuilder: (context, index) {
              final day = days[index];

              // Hack to remove ExpansiontTile divider colours
              final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);

              return Column(
                children: <Widget>[
                  
                  Theme(
                    data: theme,
                    child: ExpansionTile(
                        key: Key(index.toString()), //attention 
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
                              width: 10,
                            ),
                            if(index == 0)
                            Text(
                              'Today',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 3,
                                  color: Colors.white,
                                  fontSize: 15,),
                            ),
                          ],
                        ),
                        initiallyExpanded: index==selected,
                        onExpansionChanged: ((newState){
                          print('index = $index');
                          print('selected before = $selected');
                          
                          if(newState)
                              setState(() {
                              // selected = index;   
                          });
                          else setState(() {
                              // selected = 0; 
                            });

                          print('selected = $selected');
                        }),
                        trailing: SizedBox(
                            width: 5,
                          ),
                        children: <Widget>[
                          Divider(
                            thickness : 1,
                            color:
                                Colors.white,
                          ),
                          ForecastHorizontal(weathers: widget.weather.forecast),
                          Divider(
                            thickness : 1,
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
