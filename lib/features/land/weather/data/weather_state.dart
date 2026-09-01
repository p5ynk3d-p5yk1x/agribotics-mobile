import 'weather_models.dart';

enum WeatherStatus { initial, loading, loaded, refreshing, error }

class WeatherState {
  const WeatherState({
    this.status = WeatherStatus.initial,
    this.weather,
    this.forecast = const [],
    this.message,
  });

  final WeatherStatus status;
  final LandWeather? weather;
  final List<LandWeatherForecast> forecast;
  final String? message;

  WeatherState copyWith({WeatherStatus? status, LandWeather? weather, List<LandWeatherForecast>? forecast, String? message}) {
    return WeatherState(status: status ?? this.status, weather: weather ?? this.weather, forecast: forecast ?? this.forecast, message: message);
  }
}