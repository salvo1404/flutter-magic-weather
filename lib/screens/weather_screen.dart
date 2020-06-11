import 'package:flutter/material.dart';
import 'package:MagicWeather/models/app_model.dart';
import "package:MagicWeather/models/weather_model.dart";
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:MagicWeather/widgets/weather_widget.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum OptionsMenu { changeCity, settings }

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> with TickerProviderStateMixin {
  String _cityName = '';
  // AnimationController _fadeController;
  // Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // _fadeController = AnimationController(
    //     duration: const Duration(milliseconds: 1000), vsync: this);
    // _fadeAnimation =
    //     CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    // _loadWeatherFromMemory();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/clear-sky.jpg'),
              colorFilter: new ColorFilter.mode(Colors.white.withOpacity(0.8), BlendMode.dstATop),
              fit: BoxFit.cover
          )
      ),
      child: Scaffold(
          resizeToAvoidBottomPadding: false,
          backgroundColor: Colors.transparent,
          bottomNavigationBar: SizedBox(
            height: 85,
            child: Column(
              children: <Widget>[
                Divider(color: Colors.white, thickness: 1,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      RaisedButton(
                        child: Text(
                          "Fetch data",
                          style: TextStyle(
                              color: Colors.redAccent),
                        ),
                        onPressed: _fetchWeatherWithCity,
                      ),
                      RaisedButton(
                        child: Text(
                          "Refresh",
                          style: TextStyle(
                              color: Colors.redAccent),
                        ),
                        onPressed: _refreshWeatherData,
                      ),
                      RaisedButton(
                        child: Text(
                          "Reset City",
                          style: TextStyle(
                              color: Colors.redAccent),
                        ),
                        onPressed: _resetWeatherCity,
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
                      color: Provider.of<AppModel>(context)
                          .theme
                          .accentColor,
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
              child: Consumer<WeatherModel>(
                builder: (context, weatherModel, _) {
                  if (weatherModel.weatherState == 'empty') {
                    weatherModel.loadWeatherFromShared();
                    weatherModel.refreshWeather(3);
                  }

                  if (weatherModel.weatherState == 'loaded') {
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
                        ]
                      );
                  } else if (weatherModel.weatherState == 'error') {
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
                            "Set city from location",
                            style: TextStyle(
                                color: Colors.redAccent),
                          ),
                          onPressed: _fetchWeatherWithCity(),
                        )
                      ],
                    );
                  } else {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 200.0),
                        ),
                        Text(
                          'Loading',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            letterSpacing: 3,
                            fontSize: 50,
                            color: Colors.white
                          ),
                        ),
                      ],
                    );
                  }
                }),
            ),
          )
        ),
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

  _resetWeatherCity() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('weather');
    prefs.remove('forecast');
    prefs.remove('city');
    print('Reset weather shared');
    print('Reset forecast shared');
    print('Reset city shared');

    final weatherModel = Provider.of<WeatherModel>(context);
    weatherModel.setCity('');
    _cityName = '';
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

    weatherModel.setCity(_cityName);

    if (_cityName == '') {
      Position position = await _retrieveGeolocalization();
      weatherModel.setLocation(position.latitude, position.longitude);
    }

    weatherModel.mapFetchWeatherToState();
  }

  Future<Position> _retrieveGeolocalization() async {
    var permissionHandler = PermissionHandler();

    var permissionResult = await permissionHandler
        .requestPermissions([PermissionGroup.locationWhenInUse]);

    switch (permissionResult[PermissionGroup.locationWhenInUse]) {
      case PermissionStatus.denied:
      case PermissionStatus.unknown:
        print('location permission denied');
        _showLocationDeniedDialog(permissionHandler);
        // throw Error();
    }

    GeolocationStatus geolocationStatus  = await Geolocator().checkGeolocationPermissionStatus();
    debugPrint('Debug: $geolocationStatus');

    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    debugPrint('Debug: $position');

    return position;
  }

  _refreshWeatherData() {
    final weatherModel = Provider.of<WeatherModel>(context);
    weatherModel.refreshWeather(0);
  }

  void _showLocationDeniedDialog(PermissionHandler permissionHandler) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text('Location is disabled :(',
                style: TextStyle(color: Colors.black)),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'Enable!',
                  style: TextStyle(color: Colors.green, fontSize: 16),
                ),
                onPressed: () {
                  permissionHandler.openAppSettings();
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
