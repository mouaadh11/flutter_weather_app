import 'package:flutter/material.dart';
import 'package:flutter_weather_app/models/weather.dart';
import 'package:flutter_weather_app/services/weather_service.dart';
import 'package:lottie/lottie.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  // Placeholder for weather data
  Weather? _weather;
  final WeatherService _weatherService = WeatherService();

  _fetchWeather() async {
    try {
      // Get the current location
      Map<String, double> location = await _weatherService.getLocation();
      double lat = location['lat']!;
      double lon = location['lon']!;

      // Fetch weather data based on the current location
      Weather weather = await _weatherService.fetchWeatherByLocation(lat, lon);

      // Update the state with the fetched weather data
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print('Error fetching weather: $e');
    }
  }

  @override
  initState() {
    super.initState();
    _fetchWeather();
  }

  String _getAnimationForCondition(String condition) {
    if (condition.isEmpty) {
      return 'assets/animations/sunny.json'; // Default
    }
    
    switch (condition.toLowerCase()) {
      case 'clear':
        return 'assets/animations/sunny.json';

      case 'clouds':
        return 'assets/animations/cloudy.json';

      case 'rain':
      case 'drizzle':
        return 'assets/animations/rainy.json';

      case 'thunderstorm':
        return 'assets/animations/storm.json';

      case 'snow':
        return 'assets/animations/snowy.json';

      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
      case 'sand':
      case 'ash':
      case 'squall':
      case 'tornado':
        return 'assets/animations/windy.json';

      default:
        return 'assets/animations/windy.json'; // Fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_weather?.city ?? "Loading the city"),
            Lottie.asset(
              _getAnimationForCondition(_weather?.condition ?? ""),
              width: 250,
              height: 250,
            ),
            Text("${_weather?.temperature.round()}°C"),
            Text(_weather?.condition ?? "Loading the condition"),
          ],
        ),
      ),
    );
  }
}
