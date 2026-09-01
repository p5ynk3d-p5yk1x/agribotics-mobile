import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'land_api.dart';
import 'land_local_storage.dart';
import 'land_models.dart';

class LandRepository {
  LandRepository(this._api, this._storage);

  final LandApi _api;
  final LandLocalStorage _storage;

  Future<LandResponse> loadCurrentLand() async {
    try {
      final response = await _api.getCurrentLand();
      await _persist(response.land);
      return response;
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) await _storage.clearLandState();
      rethrow;
    }
  }

  Future<LandResponse> createLand(List<LatLng> vertices) async {
    final polygon = GeoJsonPolygon(vertices);
    final validation = polygon.validate();

    if (!validation.isValid) throw LandValidationException(validation.message ?? 'Invalid boundary.');

    final response = await _api.createLand(polygon);
    await _persist(response.land);
    return response;
  }

  Future<void> deleteCurrentLand() async {
    await _api.deleteCurrentLand();
    await _storage.clearLandState();
  }

  Future<void> clearLocalLand() => _storage.clearLandState();

  Future<void> _persist(Land land) => _storage.saveLandSnapshot(landId: land.landId, latitude: land.centroid.latitude, longitude: land.centroid.longitude, syncedAt: DateTime.now().toUtc());
}

class LandValidationException implements Exception {
  LandValidationException(this.message);

  final String message;
}