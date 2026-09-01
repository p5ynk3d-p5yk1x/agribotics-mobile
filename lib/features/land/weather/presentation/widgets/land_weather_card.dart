import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../../core/theme/app_theme.dart';
import '../../data/weather_models.dart';
import '../../data/weather_state.dart';

class LandWeatherCard extends StatelessWidget {
  const LandWeatherCard({super.key, required this.state, required this.onRefresh});

  final WeatherState state;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    if (state.status == WeatherStatus.initial || state.status == WeatherStatus.loading) return const _WeatherLoadingCard();

    if (state.status == WeatherStatus.error && state.weather == null) {
      return _WeatherErrorCard(message: state.message ?? 'Weather data unavailable.', onRetry: onRefresh);
    }

    final weather = state.weather;
    if (weather == null) return const _WeatherLoadingCard();

    final isRefreshing = state.status == WeatherStatus.refreshing;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outline.withOpacity(0.10)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.035), blurRadius: 20, offset: const Offset(0, 7))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('WEATHER AT YOUR LAND', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(weather.areaName, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.secondary)),
                  ],
                ),
              ),
              IconButton(
                onPressed: isRefreshing ? null : onRefresh,
                icon: isRefreshing ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(LucideIcons.refreshCw, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _WeatherIcon(conditionCode: weather.conditionCode),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${weather.temperature?.round() ?? '—'}°', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(_capitalize(weather.description), style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('H ${_temperature(weather.maxTemperature)}', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text('L ${_temperature(weather.minTemperature)}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.secondary)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(height: 1, color: AppTheme.outline.withOpacity(0.10)),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _WeatherMetric(icon: LucideIcons.thermometer, label: 'FEELS LIKE', value: _temperature(weather.feelsLike))),
              Expanded(child: _WeatherMetric(icon: LucideIcons.droplets, label: 'HUMIDITY', value: weather.humidity == null ? '—' : '${weather.humidity!.round()}%')),
              Expanded(child: _WeatherMetric(icon: LucideIcons.wind, label: 'WIND', value: weather.windSpeed == null ? '—' : '${(weather.windSpeed! * 3.6).toStringAsFixed(1)} km/h')),
            ],
          ),
          const SizedBox(height: 18),
          _ForecastStrip(forecast: state.forecast),
          if (state.message != null) Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text(state.message!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.secondary)),
          ),
        ],
      ),
    );
  }
}

class _ForecastStrip extends StatelessWidget {
  const _ForecastStrip({required this.forecast});

  final List<LandWeatherForecast> forecast;

  @override
  Widget build(BuildContext context) {
    final visibleForecast = forecast.take(4).toList();
    if (visibleForecast.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('UPCOMING', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.secondary, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var i = 0; i < visibleForecast.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: _ForecastItem(forecast: visibleForecast[i])),
            ],
          ],
        ),
      ],
    );
  }
}

class _ForecastItem extends StatelessWidget {
  const _ForecastItem({required this.forecast});

  final LandWeatherForecast forecast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          Text(_formatTime(forecast.date), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.secondary)),
          const SizedBox(height: 8),
          Icon(_weatherIcon(forecast.conditionCode), size: 18, color: AppTheme.primary),
          const SizedBox(height: 8),
          Text(_temperature(forecast.temperature), style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _WeatherMetric extends StatelessWidget {
  const _WeatherMetric({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 17, color: AppTheme.primary),
        const SizedBox(height: 7),
        Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.secondary)),
        const SizedBox(height: 4),
        Text(value, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _WeatherIcon extends StatelessWidget {
  const _WeatherIcon({required this.conditionCode});

  final int? conditionCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.10), borderRadius: BorderRadius.circular(18)),
      child: Icon(_weatherIcon(conditionCode), size: 28, color: AppTheme.primary),
    );
  }
}

class _WeatherLoadingCard extends StatelessWidget {
  const _WeatherLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 190,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outline.withOpacity(0.10)),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _WeatherErrorCard extends StatelessWidget {
  const _WeatherErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outline.withOpacity(0.10)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.cloudOff, color: AppTheme.outline),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: Theme.of(context).textTheme.bodyMedium)),
          const SizedBox(width: 12),
          IconButton(onPressed: onRetry, icon: const Icon(LucideIcons.refreshCw, size: 18)),
        ],
      ),
    );
  }
}

IconData _weatherIcon(int? code) {
  if (code == null) return LucideIcons.cloud;
  if (code >= 200 && code < 300) return LucideIcons.cloudLightning;
  if (code >= 300 && code < 600) return LucideIcons.cloudRain;
  if (code >= 600 && code < 700) return LucideIcons.snowflake;
  if (code >= 700 && code < 800) return LucideIcons.cloudFog;
  if (code == 800) return LucideIcons.sun;
  if (code > 800) return LucideIcons.cloudSun;
  return LucideIcons.cloud;
}

String _temperature(double? value) => value == null ? '—' : '${value.round()}°';

String _formatTime(DateTime date) {
  final local = date.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final period = local.hour >= 12 ? 'PM' : 'AM';
  return '$hour $period';
}

String _capitalize(String value) {
  if (value.isEmpty) return value;
  return '${value[0].toUpperCase()}${value.substring(1)}';
}