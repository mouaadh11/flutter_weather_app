class Weather {
  final String city;
  final String condition;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final int pressure;
  final double windSpeed;
  final DateTime sunrise;
  final DateTime sunset;

  Weather({
    required this.city,
    required this.condition,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.sunrise,
    required this.sunset,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      city: json['name'] as String,
      condition: json['weather'][0]['main'] as String,
      temperature: (json['main']['temp'] as num).toDouble(),
      feelsLike: (json['main']['feels_like'] as num).toDouble(),
      humidity: (json['main']['humidity'] as num).toInt(),
      pressure: (json['main']['pressure'] as num).toInt(),
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      sunrise: DateTime.fromMillisecondsSinceEpoch(
        (json['sys']['sunrise'] as num).toInt() * 1000,
        isUtc: true,
      ).toLocal(),
      sunset: DateTime.fromMillisecondsSinceEpoch(
        (json['sys']['sunset'] as num).toInt() * 1000,
        isUtc: true,
      ).toLocal(),
    );
  }
}
