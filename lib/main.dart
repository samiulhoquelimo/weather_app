import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/settings_page.dart';
import 'pages/weather_page.dart';
import 'providers/weather_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => WeatherProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: WeatherPage.routeName,
      routes: {
        WeatherPage.routeName: (context) => const WeatherPage(),
        SettingsPage.routeName: (context) => const SettingsPage(),
      },
    );
  }
}
