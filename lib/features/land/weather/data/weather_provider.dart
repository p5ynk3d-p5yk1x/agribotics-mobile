import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'weather_repository.dart';
import 'weather_state.dart';

const _openWeatherApiKey = String.fromEnvironment('OPENWEATHER_API_KEY');

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  if (_openWeatherApiKey.isEmpty) throw StateError('OPENWEATHER_API_KEY was not provided.');
  return WeatherRepository(apiKey: _openWeatherApiKey);
});

final weatherProvider = StateNotifierProvider<WeatherNotifier, WeatherState>((ref) => WeatherNotifier(ref.watch(weatherRepositoryProvider)));

class WeatherNotifier extends StateNotifier<WeatherState> {
  WeatherNotifier(this._repository) : super(const WeatherState());

  final WeatherRepository _repository;

  Future<void> load({required double latitude, required double longitude}) async {
    state = state.copyWith(status: WeatherStatus.loading, message: null);

    try {
      final weather = await _repository.getCurrentWeather(latitude: latitude, longitude: longitude);
      final forecast = await _repository.getForecast(latitude: latitude, longitude: longitude);
      state = WeatherState(status: WeatherStatus.loaded, weather: weather, forecast: forecast);
    } catch (error) {
      state = WeatherState(status: WeatherStatus.error, message: _message(error));
    }
  }

  Future<void> refresh({required double latitude, required double longitude}) async {
    final previous = state;
    state = state.copyWith(status: WeatherStatus.refreshing, message: null);

    try {
      final weather = await _repository.getCurrentWeather(latitude: latitude, longitude: longitude);
      final forecast = await _repository.getForecast(latitude: latitude, longitude: longitude);
      state = WeatherState(status: WeatherStatus.loaded, weather: weather, forecast: forecast);
    } catch (error) {
      state = previous.copyWith(status: WeatherStatus.loaded, message: _message(error));
    }
  }

  String _message(Object error) {
    final text = error.toString();

    if (text.contains('OPENWEATHER_API_KEY')) return 'Weather API configuration is missing.';
    if (text.contains('401')) return 'Weather service authentication failed.';
    if (text.contains('429')) return 'Weather service request limit has been reached.';

    return 'Unable to retrieve weather for your land.';
  }
}