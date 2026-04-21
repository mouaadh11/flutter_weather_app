import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import 'city_weather_page.dart';

class HomePage extends StatefulWidget {
  // ✅ StatefulWidget to hold PageController
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _showCitySearchDialog() async {
    final controller = TextEditingController();

    final selectedCity = await showDialog<String>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Search city',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter a city name',
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    autofocus: true,
                    onSubmitted: (value) =>
                        Navigator.of(context).pop(value.trim()),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                        onPressed: () =>
                            Navigator.of(context).pop(controller.text.trim()),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (selectedCity == null || selectedCity.isEmpty) return;

    final provider = context.read<WeatherProvider>();
    await provider.addCity(selectedCity); // adds + fetches weather

    // ✅ Jump to the newly added city
    final newIndex = provider.cityNames.indexOf(selectedCity);
    if (newIndex != -1) {
      _pageController.animateToPage(
        newIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, provider, _) {
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
                onPressed: _showCitySearchDialog, // ✅ fully implemented
                color: Colors.white,
              ),
              if (provider.cityNames.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  // ✅ refreshes the currently visible city
                  onPressed: () => provider.refreshCity(
                    provider.cityNames[provider.currentIndex],
                  ),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                child: provider.cityNames.isEmpty
                  ? const Center(
                      child: Text(
                        'No cities added yet.\nTap 🔍 to search for a city.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: PageView.builder(
                            controller: _pageController, // ✅ wired up
                            itemCount: provider.cityNames.length,
                            onPageChanged: provider.setPage,
                            itemBuilder: (context, index) {
                              final city = provider.cityNames[index];
                              return CityWeatherPage(
                                city: city,
                                weather: provider.weatherMap[city],
                                isLoading: provider.loadingMap[city] ?? true,
                                errorMessage: provider.errorMap[city],
                                lastUpdated: provider.lastUpdatedMap[city],
                                onRefresh: () => provider.refreshCity(city),
                              );
                            },
                          ),
                        ),
                                  
                        // ✅ Animated dot indicators
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(provider.cityNames.length, (
                              index,
                            ) {
                              final isActive = index == provider.currentIndex;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: isActive ? 12 : 8,
                                height: isActive ? 12 : 8,
                                decoration: BoxDecoration(
                                  color: isActive ? Colors.white : Colors.white54,
                                  shape: BoxShape.circle,
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
              ),
          ),
        ),
        );
      },
    );
  }
}
