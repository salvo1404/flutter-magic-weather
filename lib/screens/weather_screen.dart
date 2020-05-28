import 'package:flutter/material.dart';
import 'package:MagicWeather/state/app_state.dart';
import "package:MagicWeather/state/weather_state.dart";
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
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          elevation: 0,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                style: TextStyle(
                    color: Provider.of<AppState>(context)
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
                  color: Provider.of<AppState>(context).theme.accentColor,
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
        backgroundColor: Colors.white,
        body: Material(
          child: Container(
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
                color: Provider.of<AppState>(context).theme.primaryColor),
            child: Consumer<WeatherStateModel>(
                builder: (context, weatherStateModel, _) {
                  var weatherState = weatherStateModel.weatherState;
                  if (weatherState is WeatherLoaded) {
                    this._cityName = weatherState.weather.cityName;
                      _fadeController.reset();
                      _fadeController.forward();
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          WeatherWidget(
                            weather: weatherState.weather,
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
                    if (weatherState is WeatherError && weatherState.errorCode == 404) {
                        errorText = 'We have trouble fetching weather for $_cityName';
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
          ),
        ));
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
    // final appState = Provider.of<AppState>(context);
    // debugPrint('Debug: $appState');
    // var value1 = await appState.getRandomValue();
    // var value2 = await appState.getRandomValue();

    // appState.getRandomValuesStream().listen((value) {
    //   print('1st: $value');
    // });

    final weatherStateModel = Provider.of<WeatherStateModel>(context);
    weatherStateModel.mapFetchWeatherToState();
  }

  _setWeatherCity(String city) async {
    /**
     * Example of stream and async
     */
    // final appState = Provider.of<AppState>(context);
    // debugPrint('Debug: $appState');
    // var value1 = await appState.getRandomValue();
    // var value2 = await appState.getRandomValue();

    // appState.getRandomValuesStream().listen((value) {
    //   print('1st: $value');
    // });

    final weatherStateModel = Provider.of<WeatherStateModel>(context);
    weatherStateModel.setCity(city);
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
