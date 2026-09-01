import 'package:agribotics/core/providers/app_providers.dart';
import 'package:agribotics/features/land/satellite/data/satellite_api.dart';
import 'package:agribotics/features/land/satellite/data/satellite_repository.dart';
import 'package:agribotics/features/land/satellite/data/satellite_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final satelliteApiProvider = Provider((ref) => SatelliteApi(ref.watch(dioProvider)));
final satelliteRepositoryProvider = Provider((ref) => SatelliteRepository(ref.watch(satelliteApiProvider)));
final satelliteProvider = StateNotifierProvider<SatelliteNotifier, SatelliteState>((ref) => SatelliteNotifier(ref.watch(satelliteRepositoryProvider)));

class SatelliteNotifier extends StateNotifier<SatelliteState> {
  SatelliteNotifier(this._repository) : super(const SatelliteState());

  final SatelliteRepository _repository;

  Future<void> bootstrap() async {
    state = state.copyWith(status: SatelliteStatus.loading, message: null);

    try {
      final response = await _repository.loadCurrentSatellite();
      state = SatelliteState(status: SatelliteStatus.loaded, observation: response.observation, observationStatus: response.status, refreshPolicy: response.refreshPolicy);
    } on DioException catch (error) {
      state = state.copyWith(status: SatelliteStatus.error, message: _message(error));
    } on FormatException catch (error) {
      state = state.copyWith(status: SatelliteStatus.error, message: error.message);
    }
  }

  Future<void> refresh() async {
    final previous = state;
    state = state.copyWith(status: SatelliteStatus.refreshing, message: null);

    try {
      final response = await _repository.refreshSatellite();
      state = SatelliteState(status: SatelliteStatus.loaded, observation: response.observation, observationStatus: response.status, refreshPolicy: response.refreshPolicy, history: previous.history, mapLayers: previous.mapLayers, selectedMapLayer: previous.selectedMapLayer);
    } on DioException catch (error) {
      state = previous.copyWith(status: SatelliteStatus.loaded, message: _message(error));
    } on FormatException catch (error) {
      state = previous.copyWith(status: SatelliteStatus.loaded, message: error.message);
    }
  }

  Future<void> loadHistory({int limit = 30}) async {
    state = state.copyWith(isLoadingHistory: true, message: null);

    try {
      final history = await _repository.loadHistory(limit: limit);
      state = state.copyWith(history: history, isLoadingHistory: false);
    } on DioException catch (error) {
      state = state.copyWith(isLoadingHistory: false, message: _message(error));
    } on FormatException catch (error) {
      state = state.copyWith(isLoadingHistory: false, message: error.message);
    }
  }

  Future<void> loadMapLayers() async {
    state = state.copyWith(isLoadingMaps: true, message: null);

    try {
      final response = await _repository.loadMapLayers();
      final selected = state.selectedMapLayer ?? (response.layers.isNotEmpty ? response.layers.first : null);
      state = state.copyWith(mapLayers: response.layers, selectedMapLayer: selected, isLoadingMaps: false);
    } on DioException catch (error) {
      state = state.copyWith(isLoadingMaps: false, message: _message(error));
    } on FormatException catch (error) {
      state = state.copyWith(isLoadingMaps: false, message: error.message);
    }
  }

  void selectMapLayer(String layerId) {
    for (final layer in state.mapLayers) {
      if (layer.id == layerId) {
        state = state.copyWith(selectedMapLayer: layer);
        return;
      }
    }
  }

  String _message(DioException error) {
    final code = error.response?.statusCode;
    final data = error.response?.data;
    final backendCode = data is Map ? data['code'] : null;

    if (code == 401) return 'Your session has expired. Please log in again.';
    if (code == 403) return 'You are not authorized to access satellite data for this land.';
    if (code == 404 && backendCode == 'SATELLITE_OBSERVATION_NOT_FOUND') return 'No satellite observation is available yet.';
    if (code == 404 && backendCode == 'SATELLITE_IMAGE_NOT_FOUND') return 'The satellite image for this observation is unavailable.';
    if (code == 404) return 'Land was not found.';
    if (code == 429) {
      final retryAfter = data is Map ? data['retryAfterSeconds'] : null;
      if (retryAfter is num) return 'Refresh is not available yet. Try again in ${retryAfter.ceil()} seconds.';
      return 'Refresh is not available yet.';
    }
    if (code == 409 && backendCode == 'SATELLITE_REFRESH_IN_PROGRESS') return 'A satellite refresh is already in progress.';
    if (code == 503) return 'Satellite services are temporarily unavailable. Previous data is preserved.';

    return 'Unable to retrieve satellite data. Please check your connection and try again.';
  }
}