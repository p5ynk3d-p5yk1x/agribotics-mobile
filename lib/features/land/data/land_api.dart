import 'package:dio/dio.dart';

import 'land_models.dart';

class LandApi {
  LandApi(this._dio);
  final Dio _dio;

  Future<LandResponse> getCurrentLand() async => LandResponse.fromJson((await _dio.get('/land/current')).data as Map<String, dynamic>);

  Future<LandResponse> createLand(GeoJsonPolygon polygon) async => LandResponse.fromJson((await _dio.post('/land', data: {'geoJson': polygon.toFeatureJson()})).data as Map<String, dynamic>);

  Future<LandResponse> getLatestSatellite() async => LandResponse.fromJson((await _dio.get('/land/current/satellite')).data as Map<String, dynamic>);

  Future<LandResponse> refreshSatellite() async => LandResponse.fromJson((await _dio.post('/land/current/satellite/refresh')).data as Map<String, dynamic>);
}
