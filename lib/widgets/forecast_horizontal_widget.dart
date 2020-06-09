import 'package:flutter/material.dart';
import 'package:MagicWeather/models/weather_model.dart';
import 'package:MagicWeather/widgets/value_tile.dart';
import 'package:MagicWeather/utils/converters.dart';
import 'package:intl/intl.dart';

/// Renders a horizontal scrolling list of weather conditions
/// Used to show forecast
/// Shows DateTime, Weather Condition icon and Temperature
class ForecastHorizontal extends StatelessWidget {
  const ForecastHorizontal({
    Key key,
    @required this.weathers,
  }) : super(key: key);

  final List<Weather> weathers;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
            padding: EdgeInsets.all(5),
          ),
        Container(
          height: 70,
          
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: this.weathers.length,
            separatorBuilder: (context, index) => Divider(
                  height: 100,
                  color: Colors.white,
                ),
            padding: EdgeInsets.only(left: 5, right: 5),
            itemBuilder: (context, index) {
              final item = this.weathers[index];
              return Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Center(
                    child: ValueTile(
                  DateFormat('E, ha').format(
                      DateTime.fromMillisecondsSinceEpoch(item.time * 1000)),
                  '${item.temperature.as(TemperatureUnit.celsius).round()}°',
                  iconData: item.getIconData(),
                )),
              );
            },
          ),
        ),
        Padding(
            padding: EdgeInsets.all(5),
          ),
      ],
    );
  }
}
