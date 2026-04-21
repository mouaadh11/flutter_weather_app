// providers/weather_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_weather_app/models/weather.dart';
import 'package:flutter_weather_app/services/city_repository.dart';
import 'package:flutter_weather_app/services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  final WeatherService _service = WeatherService();
  final CityRepository _repo = CityRepository();

  List<String> cityNames = [];
  Map<String, Weather> weatherMap = {};   // city → weather data
  Map<String, bool> loadingMap = {};
  int currentIndex = 0;
  Map<String, String> errorMap = {}; // city → error message
  Map<String, DateTime> lastUpdatedMap = {}; // city → last updated time

  Future<void> init() async {
    cityNames = await _repo.getSavedCities();
    for (final city in cityNames) {
      _fetchForCity(city);
    }
  }

  Future<void> addCity(String name) async {
    if (cityNames.contains(name)) return;
    await _repo.addCity(name);
    cityNames.add(name);
    notifyListeners();
    _fetchForCity(name);
  }

  Future<void> removeCity(String name) async {
    await _repo.removeCity(name);
    cityNames.remove(name);
    weatherMap.remove(name);
    currentIndex = currentIndex.clamp(0, cityNames.length - 1);
    notifyListeners();
  }

  Future<void> _fetchForCity(String city) async {
    loadingMap[city] = true;
    notifyListeners();
    try {
      weatherMap[city] = await _service.fetchWeatherByCity(city);
    } catch (_) {}
    loadingMap[city] = false;
    notifyListeners();
  }
  Future<void> refreshCity(String city) async => _fetchForCity(city);


  void setPage(int index) {
    currentIndex = index;
    notifyListeners();
  }
}