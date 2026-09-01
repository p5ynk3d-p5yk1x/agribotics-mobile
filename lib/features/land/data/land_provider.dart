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
    state = state.copyWith(status: LandStatus.loading, message: null, isStale: false);

    try {
      final response = await _repository.loadCurrentLand();
      state = LandState(status: LandStatus.loaded, land: response.land);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        await _repository.clearLocalLand();
        state = const LandState(status: LandStatus.noLand);
        return;
      }

      state = LandState(status: LandStatus.error, message: _message(error));
    } on FormatException catch (error) {
      state = LandState(status: LandStatus.error, message: error.message);
    }
  }

  Future<void> saveLand(List<LatLng> vertices) async {
    state = state.copyWith(status: LandStatus.saving, message: null);

    try {
      final response = await _repository.createLand(vertices);
      state = LandState(status: LandStatus.loaded, land: response.land);
    } on LandValidationException catch (error) {
      state = state.copyWith(status: LandStatus.selecting, message: error.message);
    } on DioException catch (error) {
      state = state.copyWith(status: LandStatus.error, message: _message(error), isStale: state.land != null);
    } on FormatException catch (error) {
      state = state.copyWith(status: LandStatus.error, message: error.message);
    }
  }

  Future<void> deleteLand() async {
    state = state.copyWith(status: LandStatus.deleting, message: null);

    try {
      await _repository.deleteCurrentLand();
      state = const LandState(status: LandStatus.noLand);
    } on DioException catch (error) {
      state = state.copyWith(status: LandStatus.error, message: _message(error));
    }
  }

  String _message(DioException error) {
    final code = error.response?.statusCode;

    if (code == 401) return 'Your session has expired. Please log in again.';
    if (code == 403) return 'You are not authorized to access this land.';
    if (code == 404) return 'Land was not found.';
    if (code == 409) return 'A land record already exists for this account.';
    if (code == 400 || code == 422) return 'The land boundary was rejected by the server.';

    return 'Unable to retrieve land data. Please check your connection and try again.';
  }
}