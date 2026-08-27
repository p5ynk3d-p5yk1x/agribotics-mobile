import 'package:agribotics/core/providers/app_providers.dart';
import 'package:agribotics/features/land/data/land_api.dart';
import 'package:agribotics/features/land/data/land_local_storage.dart';
import 'package:agribotics/features/land/data/land_repository.dart';
import 'package:agribotics/features/land/data/land_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final landLocalStorageProvider = Provider((ref) => LandLocalStorage());
final landApiProvider = Provider((ref) => LandApi(ref.watch(dioProvider)));
final landRepositoryProvider = Provider((ref) => LandRepository(ref.watch(landApiProvider), ref.watch(landLocalStorageProvider)));
final landProvider = StateNotifierProvider<LandNotifier, LandState>((ref) => LandNotifier(ref.watch(landRepositoryProvider)));

class LandNotifier extends StateNotifier<LandState> {
  LandNotifier(this._repository) : super(const LandState());
  final LandRepository _repository;

  Future<void> bootstrap() async {
    state = state.copyWith(status: LandStatus.checkingLocalState);
    final localId = await _repository.readLocalLandId();
    if (localId == null || localId.isEmpty) { state = const LandState(status: LandStatus.noLand); return; }
    state = state.copyWith(status: LandStatus.loadingExistingLand);
    try {
      final response = await _repository.loadCurrentLand();
      if (response == null) state = const LandState(status: LandStatus.noLand); else state = LandState(status: LandStatus.loaded, land: response.land, refreshPolicy: response.refreshPolicy);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) state = const LandState(status: LandStatus.noLand); else state = state.copyWith(status: LandStatus.error, message: _message(error), isStale: state.land != null);
    }
  }

  Future<void> saveLand(List<LatLng> vertices) async {
    state = state.copyWith(status: LandStatus.saving, message: null);
    try {
      final response = await _repository.createLand(vertices);
      state = LandState(status: LandStatus.loaded, land: response.land, refreshPolicy: response.refreshPolicy);
    } on LandValidationException catch (error) {
      state = state.copyWith(status: LandStatus.selecting, message: error.message);
    } on DioException catch (error) {
      state = state.copyWith(status: LandStatus.error, message: _message(error), isStale: state.land != null);
    }
  }

  Future<void> refreshSatellite() async {
    final previous = state;
    state = state.copyWith(status: LandStatus.refreshing, message: null);
    try {
      final response = await _repository.refreshSatellite();
      state = LandState(status: LandStatus.loaded, land: response.land, refreshPolicy: response.refreshPolicy);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) { await _repository.clearLocalLand(); state = const LandState(status: LandStatus.noLand); return; }
      state = previous.copyWith(status: LandStatus.loaded, message: _message(error), isStale: true);
    }
  }

  String _message(DioException error) {
    final code = error.response?.statusCode;
    if (code == 429) return 'Refresh is not available yet. Please retry when the server countdown ends.';
    if (code == 422) return 'The land boundary was rejected by the server.';
    if (code == 403) return 'You are not authorized to access this land.';
    if (code == 409) return 'The land state changed. Reload and try again.';
    return 'Satellite service is temporarily unavailable. Previous data is preserved.';
  }
}
