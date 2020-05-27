import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:MagicWeather/state/app_state.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Provider.of<AppState>(context).theme.primaryColor,
        title: Text("Settings"),
      )
    );
  }
}
