import 'dart:convert';

import 'package:flutter_weather_app/models/weather.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  static const String _apiKey = 'affb83808f858a592608394dd66cc5fb';

  Future<Map<String, double>> getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    return {
      'lat': position.latitude,
      'lon': position.longitude,
    };
  }


  Future<Weather> fetchWeatherByLocation(double lat, double lon) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric'),
    );

    if (response.statusCode == 200) {
      return Weather.fromJson(json.decode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load weather');
    }
  }
}
