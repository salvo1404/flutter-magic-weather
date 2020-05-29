import 'package:flutter/material.dart';
import 'package:MagicWeather/models/app_model.dart';
import "package:MagicWeather/models/weather_model.dart";
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:MagicWeather/widgets/weather_widget.dart';

enum OptionsMenu { changeCity, settings }

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with TickerProviderStateMixin {
  String _cityName = 'bengaluru';
  AnimationController _fadeController;
  Animation<double> _fadeAnimation;

@override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    // _fetchWeatherWithCity();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/beach.jpg'),
              colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.5), BlendMode.dstATop),
              fit: BoxFit.cover
          )
      ),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                  style: TextStyle(
                      color: Provider.of<AppModel>(context)
                          .theme
                          .accentColor
                          .withAlpha(80),
                      fontSize: 14),
                )
              ],
            ),
            actions: <Widget>[
              PopupMenuButton<OptionsMenu>(
                  child: Icon(
                    Icons.more_vert,
                    color: Provider.of<AppModel>(context).theme.accentColor,
                  ),
                  onSelected: this._onOptionMenuItemSelected,
                  itemBuilder: (context) => <PopupMenuEntry<OptionsMenu>>[
                        PopupMenuItem<OptionsMenu>(
                          value: OptionsMenu.changeCity,
                          child: Text("Select city"),
                        ),
                        PopupMenuItem<OptionsMenu>(
                          value: OptionsMenu.settings,
                          child: Text("Settings"),
                        ),
                      ])
            ],
          ),
          body: Container(
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration( color: Colors.transparent),
            child: Consumer<WeatherModel>(
                builder: (context, weatherModel, _) {
                  
                  if (weatherModel.weatherState == 'loaded') {
                    this._cityName = weatherModel.weather.cityName;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          WeatherWidget(
                            weather: weatherModel.weather,
                          ),
                          RaisedButton(
                            child: Text(
                              "Fetch Again",
                              style: TextStyle(
                                  color: Colors.redAccent),
                            ),
                            onPressed: _fetchWeatherWithCity,
                          )
                        ]
                      );
                  } else {
                    String errorText = 'Please select a city';
                    if (weatherModel.weatherState == 'error' && weatherModel.errorCode == 404) {
                        errorText = 'Trouble fetching weather for $_cityName';
                    }
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.error_outline,
                          color: Colors.redAccent,
                          size: 36,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          errorText,
                          style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 24
                          ),
                        ),
                        Padding(
                          child: Divider(
                            color:
                                Colors.white.withAlpha(50),
                          ),
                          padding: EdgeInsets.all(10),
                        ),
                        RaisedButton(
                          child: Text(
                            "Try Again",
                            style: TextStyle(
                                color: Colors.redAccent),
                          ),
                          onPressed: _fetchWeatherWithCity,
                        )
                      ],
                    );
                  }
                }),
          )),
    );
  }

  _onOptionMenuItemSelected(OptionsMenu item) {
    switch (item) {
      case OptionsMenu.changeCity:
        this._showCityChangeDialog();
        break;
      case OptionsMenu.settings:
        Navigator.of(context).pushNamed("/settings");
        break;
    }
  }

  _fetchWeatherWithCity() async {
    /**
     * Example of stream and async
     */
    // final appModel = Provider.of<AppModel>(context);
    // debugPrint('Debug: $appModel');
    // var value1 = await appModel.getRandomValue();
    // var value2 = await appModel.getRandomValue();

    // appModel.getRandomValuesStream().listen((value) {
    //   print('1st: $value');
    // });

    final weatherModel = Provider.of<WeatherModel>(context);
    weatherModel.mapFetchWeatherToState();
  }

  _setWeatherCity(String city) async {
        final weatherModel = Provider.of<WeatherModel>(context);
    weatherModel.setCity(city);
  }

  void _showCityChangeDialog() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text('Select city', style: TextStyle(color: Colors.black)),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'ok',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                onPressed: () {
                  _fetchWeatherWithCity();
                  Navigator.of(context).pop();
                },
              ),
            ],
            content: TextField(
              autofocus: true,
              onChanged: (text) {
                _cityName = text;
                _setWeatherCity(_cityName);
              },
              decoration: InputDecoration(
                  hintText: 'Name of your city',
                  hintStyle: TextStyle(color: Colors.black),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      _fetchWeatherWithCity().catchError((error) {
                        // _fetchWeatherWithCity();
                      });
                      Navigator.of(context).pop();
                    },
                    child: Icon(
                      Icons.my_location,
                      color: Colors.black,
                      size: 16,
                    ),
                  )),
              style: TextStyle(color: Colors.black),
              cursorColor: Colors.black,
            ),
          );
        });
  }
}
