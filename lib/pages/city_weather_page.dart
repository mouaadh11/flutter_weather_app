
import 'package:flutter/material.dart';
import 'package:flutter_weather_app/models/weather.dart';
import 'package:lottie/lottie.dart';

class CityWeatherPage extends StatelessWidget {
  final String city;
  final Weather? weather;
  final bool isLoading;
  final String? errorMessage;
  final DateTime? lastUpdated;
  final Future<void> Function() onRefresh;

  const CityWeatherPage({
    super.key,
    required this.city,
    required this.weather,
    required this.isLoading,
    required this.onRefresh,
    this.errorMessage,
    this.lastUpdated,
  });

  String _formatTime(BuildContext context, DateTime dateTime) {
    return TimeOfDay.fromDateTime(dateTime).format(context);
  }

  String _getAnimationForCondition(String condition) {
    if (condition.isEmpty) return 'assets/animations/sunny.json';

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
        return 'assets/animations/windy.json';
    }
  }

  Widget _buildMetricTile(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(255, 255, 255, 0.18),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.14),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Text(
            weather!.city, // ✅ was _weather!.city
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${weather!.temperature.toStringAsFixed(0)}°C',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 62,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            weather!.condition,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 20,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),
          Lottie.asset(
            _getAnimationForCondition(weather!.condition),
            width: 220,
            height: 220,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    // ✅ context passed in
    return Column(
      children: [
        Row(
          children: [
            _buildMetricTile(
              Icons.thermostat_rounded,
              'Feels like',
              '${weather!.feelsLike.toStringAsFixed(0)}°C',
            ),
            _buildMetricTile(
              Icons.water_drop,
              'Humidity',
              '${weather!.humidity}%',
            ),
          ],
        ),
        Row(
          children: [
            _buildMetricTile(
              Icons.air,
              'Wind',
              '${weather!.windSpeed.toStringAsFixed(1)} m/s',
            ),
            _buildMetricTile(
              Icons.speed,
              'Pressure',
              '${weather!.pressure} hPa',
            ),
          ],
        ),
        Row(
          children: [
            _buildMetricTile(
              Icons.wb_sunny,
              'Sunrise',
              _formatTime(context, weather!.sunrise), // ✅ context passed
            ),
            _buildMetricTile(
              Icons.nights_stay,
              'Sunset',
              _formatTime(context, weather!.sunset),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return RefreshIndicator(
      onRefresh: onRefresh, // ✅ uses callback prop
      child: SingleChildScrollView (
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical:0),
        child: isLoading // ✅ was _isLoading
            ? SizedBox(
                height:
                    height -
                    kToolbarHeight -
                    MediaQuery.of(context).padding.vertical,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            : errorMessage !=
                  null // ✅ was _errorMessage
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white, size: 72),
                    const SizedBox(height: 16),
                    const Text(
                      'Unable to load weather',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: onRefresh, // ✅ uses callback prop
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  _buildWeatherCard(),
                  const SizedBox(height: 24),
                  _buildDetailsSection(context), // ✅ context passed
                  const SizedBox(height: 20),
                  Text(
                    lastUpdated ==
                            null // ✅ was _lastUpdated
                        ? 'Updated just now'
                        : 'Last updated: ${_formatTime(context, lastUpdated!)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
      ),
    );
  }
}
