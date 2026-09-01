import 'package:weather/weather.dart';

import 'weather_models.dart';

class WeatherRepository {
  WeatherRepository({required String apiKey}) : _factory = WeatherFactory(apiKey, language: Language.ENGLISH);

  final WeatherFactory _factory;

  Future<LandWeather> getCurrentWeather({required double latitude, required double longitude}) async {
    final weather = await _factory.currentWeatherByLocation(latitude, longitude);
    return _mapCurrentWeather(weather);
  }

  Future<List<LandWeatherForecast>> getForecast({required double latitude, required double longitude}) async {
    final forecast = await _factory.fiveDayForecastByLocation(latitude, longitude);
    return forecast.map(_mapForecast).toList();
  }

  LandWeather _mapCurrentWeather(Weather weather) {
    return LandWeather(
      areaName: weather.areaName ?? 'Your Land',
      temperature: weather.temperature?.celsius,
      feelsLike: weather.tempFeelsLike?.celsius,
      minTemperature: weather.tempMin?.celsius,
      maxTemperature: weather.tempMax?.celsius,
      humidity: weather.humidity,
      windSpeed: weather.windSpeed,
      cloudiness: weather.cloudiness,
      condition: weather.weatherMain ?? 'Unknown',
      description: weather.weatherDescription ?? 'Weather data unavailable',
      conditionCode: weather.weatherConditionCode,
      observedAt: weather.date,
    );
  }

  LandWeatherForecast _mapForecast(Weather weather) {
    return LandWeatherForecast(
      date: weather.date ?? DateTime.now(),
      temperature: weather.temperature?.celsius,
      condition: weather.weatherMain ?? 'Unknown',
      conditionCode: weather.weatherConditionCode,
    );
  }
}