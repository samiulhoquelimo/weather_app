import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/pages/settings_page.dart';
import 'package:weather_app/utils/text_styles.dart';

import '../providers/weather_provider.dart';
import '../utils/constant.dart';
import '../utils/helper_functions.dart';
import '../utils/location_service.dart';

class WeatherPage extends StatefulWidget {
  static const String routeName = '/';

  const WeatherPage({Key? key}) : super(key: key);

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  late WeatherProvider provider;
  bool isFirst = true;
  bool isConnected = true;
  late StreamSubscription<ConnectivityResult> subscription;

  @override
  void initState() {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        isConnected = result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi;
      });
    });
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
    subscription.cancel();
  }

  @override
  void didChangeDependencies() {
    if (isFirst) {
      provider = Provider.of<WeatherProvider>(context);
      _getData();
      isFirst = false;
    }
    super.didChangeDependencies();
  }

  _getData() {
    determinePosition().then((position) async {
      print('${position.latitude} ${position.longitude}');
      provider.setNewPosition(position.latitude, position.longitude);
      provider.setTempUnitData(await getTempStatus());
      provider.getWeatherData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          elevation: 0,
          title: const Text(
            'Weather App',
          ),
          actions: [
            IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: () {
                  _getData();
                }),
            IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: _CitySearchDelegate(),
                  ).then((city) {
                    if (city != null && city.isNotEmpty) {
                      provider.convertCityToLatLng(city);
                    }
                  });
                }),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () =>
                  Navigator.pushNamed(context, SettingsPage.routeName),
            ),
          ],
        ),
        body: !isConnected
            ? ListTile(
                tileColor: Colors.black,
                title: Text(
                  'No internet connection',
                  style: txtNormalTemp16,
                ),
                trailing: TextButton(
                  onPressed: () {},
                  child: const Text('Retry'),
                ),
              )
            : provider.hasDataLoaded
                ? ListView(
                    padding: const EdgeInsets.all(15),
                    children: [
                      _buildCurrentWeatherSection(),
                      const SizedBox(
                        height: 50,
                      ),
                      _buildForecastSection2()
                    ],
                  )
                : Center(
                    child: Text(
                      'Please wait...',
                      style: txtNormalTemp16,
                    ),
                  ));
  }

  Widget _buildCurrentWeatherSection() {
    final current = provider.currentWeatherModel;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          getFormattedDate(current!.dt!, 'MMM dd, yyyy hh:mm a'),
          style: txtDate18,
        ),
        Text(
          '${current.name}, ${current.sys!.country}',
          style: txtAddress22,
        ),
        Text(
          '${current.main!.temp!.round()}$degree${provider.unitSymbol}',
          style: txtBigTemp80,
        ),
        Text(
          'feels like ${current.main!.feelsLike!.round()}$degree${provider.unitSymbol}',
          style: txtNormalTemp16,
        ),
        Image.network(
          '$iconPrefix${current.weather![0].icon}$iconSuffix',
        ),
        Text(
          current.weather![0].description!,
          style: txtLabel16,
        )
      ],
    );
  }

  Widget _buildForecastSection2() {
    return Column(
      children: provider.forecastWeatherModel!.list!
          .map((e) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getFormattedDate(e.dt!, 'EEE HH:mm'),
                    style: txtLabel16,
                  ),
                  Text(
                    '${e.main!.temp!.round()}$degree',
                    style: txtNormalTemp16,
                  ),
                  Image.network(
                    '$iconPrefix${e.weather![0].icon}$iconSuffix',
                    width: 40,
                    height: 40,
                  ),
                  Text(
                    '${e.main!.tempMax!.round()}$degree/${e.main!.tempMin!.round()}$degree',
                    style: txtNormalTemp16,
                  ),
                ],
              ))
          .toList(),
    );
  }
}

class _CitySearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListTile(
      onTap: () {
        close(context, query);
      },
      leading: const Icon(Icons.search),
      title: Text(query),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredList = query.isEmpty
        ? cities
        : cities
            .where((city) => city.toLowerCase().startsWith(query.toLowerCase()))
            .toList();
    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          query = filteredList[index];
          close(context, query);
        },
        title: Text(filteredList[index]),
      ),
    );
  }
}
