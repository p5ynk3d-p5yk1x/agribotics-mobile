class LandWeather {
  const LandWeather({
    required this.areaName,
    required this.temperature,
    required this.feelsLike,
    required this.minTemperature,
    required this.maxTemperature,
    required this.humidity,
    required this.windSpeed,
    required this.cloudiness,
    required this.condition,
    required this.description,
    required this.conditionCode,
    required this.observedAt,
  });

  final String areaName;
  final double? temperature;
  final double? feelsLike;
  final double? minTemperature;
  final double? maxTemperature;
  final double? humidity;
  final double? windSpeed;
  final double? cloudiness;
  final String condition;
  final String description;
  final int? conditionCode;
  final DateTime? observedAt;
}

class LandWeatherForecast {
  const LandWeatherForecast({required this.date, required this.temperature, required this.condition, required this.conditionCode});

  final DateTime date;
  final double? temperature;
  final String condition;
  final int? conditionCode;
}