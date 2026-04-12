class Weather {
  final String city;
  final String condition;
  final double temperature;

  Weather({
    required this.city,
    required this.condition,
    required this.temperature,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      city: json['name'],
      condition: json['weather'][0]['main'],
      temperature: json['main']['temp'].toDouble(),
    );
  }
}
