import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as Geo;
import 'package:http/http.dart' as Http;
import 'package:weather_app/models/current_weather_response.dart';
import 'package:weather_app/models/forecast_weather_response.dart';

import '../utils/constant.dart';

class WeatherProvider extends ChangeNotifier {
  double latitude = 0.0, longitude = 0.0;
  CurrentWeatherResponse? currentWeatherModel;
  ForecastWeatherResponse? forecastWeatherModel;
  String unit = metric;
  String unitSymbol = celsius;

  setNewPosition(double lat, double lng) {
    latitude = lat;
    longitude = lng;
  }

  setTempUnitData(bool status) {
    unit = status ? imperial : metric;
    unitSymbol = status ? fahrenheit : celsius;
    notifyListeners();
  }

  bool get hasDataLoaded =>
      currentWeatherModel != null && forecastWeatherModel != null;

  void getWeatherData() {
    _getCurrentData();
    _getForecastData();
  }

  void _getCurrentData() async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=$unit&appid=$weather_api_key';
    try {
      final response = await Http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final map = json.decode(response.body);
        currentWeatherModel = CurrentWeatherResponse.fromJson(map);
        notifyListeners();
      } else {
        print('Invalid response');
      }
    } catch (error) {
      throw error;
    }
  }

  void _getForecastData() async {
    final url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$latitude&lon=$longitude&units=$unit&appid=$weather_api_key';
    try {
      final response = await Http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final map = json.decode(response.body);
        forecastWeatherModel = ForecastWeatherResponse.fromJson(map);
        notifyListeners();
      } else {
        print('Invalid response');
      }
    } catch (error) {
      throw error;
    }
  }

  void convertCityToLatLng(String city) async {
    try {
      final locationList = await Geo.locationFromAddress(city);
      if (locationList.isNotEmpty) {
        final location = locationList.first;
        latitude = location.latitude;
        longitude = location.longitude;
        getWeatherData();
      }
    } catch (error) {}
  }
}
