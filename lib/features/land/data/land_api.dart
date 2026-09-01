import 'package:dio/dio.dart';
import 'land_models.dart';

class LandApi {
  LandApi(this._dio);

  final Dio _dio;

  Future<LandResponse> getCurrentLand() async {
    final response = await _dio.get('/api/land/current');
    return LandResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<LandResponse> createLand(GeoJsonPolygon polygon) async {
    final response = await _dio.post('/api/land', data: {'geometry': polygon.toGeometryJson()});
    return LandResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> deleteCurrentLand() async {
    await _dio.delete('/api/land/current');
  }
}