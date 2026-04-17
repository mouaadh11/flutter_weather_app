import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import 'city_weather_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // call your existing search dialog
              // you can move _showCitySearchDialog here later
            },
          ),
        ],
      ),

      body: Consumer<WeatherProvider>(
        builder: (context, provider, _) {
          if (provider.cityNames.isEmpty) {
            return const Center(child: Text('No cities added'));
          }

          return Column(
            children: [
              Expanded(
                child: PageView.builder(
                  itemCount: provider.cityNames.length,
                  onPageChanged: provider.setPage,
                  itemBuilder: (context, index) {
                    final city = provider.cityNames[index];

                    return CityWeatherPage(
                      city: city,
                      weather: provider.weatherMap[city],
                      isLoading: provider.loadingMap[city] ?? true,
                      errorMessage: provider
                          .errorMap[city], // add errorMap to your provider
                      lastUpdated: provider
                          .lastUpdatedMap[city], // add lastUpdatedMap to your provider
                      onRefresh: () => provider.refreshCity(city),
                      onAddCity: (newCity) => provider.addCity(newCity),
                    );
                  },
                ),
              ),

              // 🔵 DOT INDICATORS
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(provider.cityNames.length, (index) {
                  final isActive = index == provider.currentIndex;

                  return Container(
                    margin: const EdgeInsets.all(4),
                    width: isActive ? 12 : 8,
                    height: isActive ? 12 : 8,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.white : Colors.white54,
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }
}
