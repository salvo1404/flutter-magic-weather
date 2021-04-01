import 'package:flutter/material.dart';
import 'package:magic_weather/models/app_model.dart';
import "package:magic_weather/models/weather_model.dart";
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:magic_weather/widgets/weather_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum OptionsMenu { changeCity, settings }

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with TickerProviderStateMixin {
  String _cityName = '';
  bool isLocationActive = false;

  @override
  void initState() {
    super.initState();
    _setLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/clear-sky.jpg'),
              colorFilter: new ColorFilter.mode(
                  Colors.white.withOpacity(0.8), BlendMode.dstATop),
              fit: BoxFit.cover)),
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          bottomNavigationBar: SizedBox(
            height: 85,
            child: Column(
              children: <Widget>[
                Divider(
                  color: Colors.white,
                  thickness: 1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      child: Text(
                        "Relaunch app",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                      onPressed: _fetchWeather,
                    ),
                    ElevatedButton(
                      child: Text(
                        "Pull Fresh Data",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                      onPressed: _refreshWeatherData,
                    ),
                    ElevatedButton(
                      child: Text(
                        "Reset cache",
                        style: TextStyle(color: Colors.redAccent),
                      ),
                      onPressed: _resetWeatherCache,
                    ),
                  ],
                ),
              ],
            ),
          ),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                  style: TextStyle(
                      color: Provider.of<AppModel>(context).theme.accentColor,
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
            child: SingleChildScrollView(
              child:
                  Consumer<WeatherModel>(builder: (context, weatherModel, _) {
                print(
                    'Weather Model render. Weather State = ${weatherModel.weatherState}');

                switch (weatherModel.weatherState) {
                  case 'cached':
                    {
                      this._cityName = weatherModel.weather.cityName;
                      return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            WeatherWidget(
                              weather: weatherModel.weather,
                            ),
                            Padding(
                              padding: EdgeInsets.all(10),
                            ),
                            Padding(
                              padding: EdgeInsets.all(20),
                            ),
                          ]);
                    }
                    break;
                  case 'error':
                    {
                      String errorText = 'Error fetching data';
                      if (weatherModel.errorCode == 404) {
                        errorText = 'Trouble fetching weather for $_cityName';
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            child: Divider(
                              color: Colors.white.withAlpha(50),
                            ),
                            padding: EdgeInsets.all(100),
                          ),
                          Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                            size: 80,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            errorText,
                            style: TextStyle(
                                color: Colors.redAccent, fontSize: 36),
                          ),
                          Padding(
                            child: Divider(
                              color: Colors.white.withAlpha(50),
                            ),
                            padding: EdgeInsets.all(10),
                          ),
                          ElevatedButton(
                              child: Text(
                                "Refresh location",
                                style: TextStyle(color: Colors.redAccent),
                              ),
                              onPressed: () {
                                _fetchWeather();
                              })
                        ],
                      );
                    }
                    break;

                  default:
                    _fetchWeather();
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 200.0),
                        ),
                        Text(
                          'Loading...',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              letterSpacing: 3,
                              fontSize: 50,
                              color: Colors.white),
                        ),
                      ],
                    );
                }
              }),
            ),
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

  _resetWeatherCache() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('weather');
    prefs.remove('forecast');
    prefs.remove('city');
    print('Reset weather shared');
    print('Reset forecast shared');
    print('Reset city shared');
  }

  _setLocation() async {
    final weatherModel = Provider.of<WeatherModel>(context, listen: false);
    Position position = await _retrieveGeolocalization();
    weatherModel.setLocation(position.latitude, position.longitude);
    print('Set location from GPS');

    setState(() {
      this.isLocationActive = true;
    });
  }

  _fetchWeather({useCache = true}) async {
    print('Fetching weather');

    final weatherModel = Provider.of<WeatherModel>(context, listen: false);

    if (useCache) {
      weatherModel.setWeatherFromCache();

      await Future.delayed(Duration(seconds: 2));

      if (weatherModel.weatherState == 'cached') {
        print('Wheather fetched from cache');
        return;
      }
    }

    if (!this.isLocationActive) {
      print('Location is not active');
      return;
    }

    weatherModel.setCity(_cityName);

    weatherModel.setWeatherFromLocation();
  }

  Future<Position> _retrieveGeolocalization() async {
    Position position;

    try {
      var locationStatus = await Permission.location.request();

      if (locationStatus.isDenied) {
        print('location permission denied');
        _showLocationDeniedDialog();
      }

      position = await Geolocator.getCurrentPosition();
    } catch (e) {
      _showLocationDeniedDialog();
    }

    return position;
  }

  _refreshWeatherData() {
    final weatherModel = Provider.of<WeatherModel>(context, listen: false);
    weatherModel.refreshWeather(0);
  }

  void _showLocationDeniedDialog() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text('Location is disabled :(',
                style: TextStyle(color: Colors.black)),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'Enable!',
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
                onPressed: () {
                  openAppSettings();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
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
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                onPressed: () {
                  _refreshWeatherData();
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(
                  'Ok',
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
                onPressed: () {
                  _fetchWeather(useCache: false);
                  Navigator.of(context).pop();
                },
              ),
            ],
            content: TextField(
              autofocus: true,
              onChanged: (text) {
                _cityName = text;
              },
              decoration: InputDecoration(
                  hintText: 'Name of your city',
                  hintStyle: TextStyle(color: Colors.black),
                  suffixIcon: GestureDetector(
                    onTap: () {
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
