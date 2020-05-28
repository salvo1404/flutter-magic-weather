import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:MagicWeather/models/app_model.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Provider.of<AppModel>(context).theme.primaryColor,
        title: Text("Settings"),
      )
    );
  }
}
