import 'package:dio/dio.dart';

import 'satellite_models.dart';

class SatelliteApi {
  SatelliteApi(this._dio);

  final Dio _dio;

  Future<SatelliteResponse> getCurrentSatellite() async {
    final response = await _dio.get('/api/land/current/satellite');
    return SatelliteResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<SatelliteResponse> refreshSatellite() async {
    final response = await _dio.post('/api/land/current/satellite/refresh');
    return SatelliteResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<SatelliteObservation>> getHistory({int limit = 30}) async {
    final response = await _dio.get('/api/land/current/satellite/history', queryParameters: {'limit': limit});
    final data = response.data;
    if (data is! List) throw const FormatException('Satellite history response is invalid.');
    return data.whereType<Map<String, dynamic>>().map(SatelliteObservation.fromJson).toList();
  }

  Future<SatelliteMapResponse> getMapLayers() async {
    final response = await _dio.get('/api/land/current/maps');
    return SatelliteMapResponse.fromJson(response.data as Map<String, dynamic>);
  }
}