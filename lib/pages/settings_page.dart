import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/utils/constant.dart';

import '../providers/weather_provider.dart';
import '../utils/helper_functions.dart';

class SettingsPage extends StatefulWidget {
  static const String routeName = '/settings';

  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late WeatherProvider provider;
  bool isOn = false;

  @override
  void didChangeDependencies() {
    provider = Provider.of<WeatherProvider>(context, listen: false);
    setState(() {
      isOn = provider.unit == imperial;
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            value: isOn,
            onChanged: (value) async {
              setState(() {
                isOn = value;
              });
              await setTempStatus(isOn);
              provider.setTempUnitData(isOn);
              provider.getWeatherData();
            },
            title: const Text('Show temperature in Fahrenheit'),
            subtitle: const Text('Default is Celsius'),
          ),
        ],
      ),
    );
  }
}
