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
  Weather? _weather;
  bool _isLoading = true;
  String? _errorMessage;
  DateTime? _lastUpdated;
  String? _searchedCity;
  final WeatherService _weatherService = WeatherService();

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather({String? city}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final Weather weather;

      if (city != null && city.isNotEmpty) {
        weather = await _weatherService.fetchWeatherByCity(city);
        _searchedCity = city;
      } else {
        final location = await _weatherService.getLocation();
        weather = await _weatherService.fetchWeatherByLocation(
          location['lat']!,
          location['lon']!,
        );
        _searchedCity = null;
      }

      if (!mounted) return;
      setState(() {
        _weather = weather;
        _lastUpdated = DateTime.now();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatTime(DateTime dateTime) {
    return TimeOfDay.fromDateTime(dateTime).format(context);
  }

  String _getAnimationForCondition(String condition) {
    if (condition.isEmpty) {
      return 'assets/animations/sunny.json';
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
            _weather!.city,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${_weather!.temperature.toStringAsFixed(0)}°C',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 62,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _weather!.condition,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 20,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 20),
          Lottie.asset(
            _getAnimationForCondition(_weather!.condition),
            width: 220,
            height: 220,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      children: [
        Row(
          children: [
            _buildMetricTile(Icons.thermostat_rounded, 'Feels like', '${_weather!.feelsLike.toStringAsFixed(0)}°C'),
            _buildMetricTile(Icons.water_drop, 'Humidity', '${_weather!.humidity}%'),
          ],
        ),
        Row(
          children: [
            _buildMetricTile(Icons.air, 'Wind', '${_weather!.windSpeed.toStringAsFixed(1)} m/s'),
            _buildMetricTile(Icons.speed, 'Pressure', '${_weather!.pressure} hPa'),
          ],
        ),
        Row(
          children: [
            _buildMetricTile(Icons.wb_sunny, 'Sunrise', _formatTime(_weather!.sunrise)),
            _buildMetricTile(Icons.nights_stay, 'Sunset', _formatTime(_weather!.sunset)),
          ],
        ),
      ],
    );
  }

  Future<void> _showCitySearchDialog() async {
    final controller = TextEditingController(text: _searchedCity ?? '');
    final selectedCity = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search city'),
          content: TextField(
            controller: controller,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              hintText: 'Enter a city name',
            ),
            autofocus: true,
            onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Search'),
            ),
          ],
        );
      },
    );

    if (selectedCity != null && selectedCity.isNotEmpty) {
      await _fetchWeather(city: selectedCity);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Weather Dashboard'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showCitySearchDialog,
            color: Colors.white,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchWeather(city: _searchedCity),
            color: Colors.white,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A90E2), Color(0xFF50C9CE)],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _fetchWeather,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 0),
              child:  _isLoading
                    ? SizedBox(
                        height: height - kToolbarHeight - MediaQuery.of(context).padding.vertical,
                      child: const Center(child: CircularProgressIndicator(color: Colors.white)))
                    : _errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, color: Colors.white, size: 72),
                                const SizedBox(height: 16),
                                const Text(
                                  'Unable to load weather',
                                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: _fetchWeather,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : Column( // the erreur is here
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // const SizedBox(height: 10),
                              _buildWeatherCard(),
                              const SizedBox(height: 24),
                              _buildDetailsSection(),
                              const SizedBox(height: 20),
                              Text(
                                _lastUpdated == null
                                    ? 'Updated just now'
                                    : 'Last updated: ${_formatTime(_lastUpdated!)}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
            ),
          ),
        ),
      ),
    );
  }
}
