import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SatelliteTileProvider extends TileProvider {
  SatelliteTileProvider(this._dio, this.layerId);

  final Dio _dio;
  final String layerId;

  @override
  Future<Tile> getTile(int x, int y, int? zoom) async {
    if (zoom == null) return TileProvider.noTile;

    try {
      final response = await _dio.get<List<int>>('/api/land/current/maps/$layerId/tiles/$zoom/$x/$y', options: Options(responseType: ResponseType.bytes));
      final data = response.data;
      if (data == null || data.isEmpty) return TileProvider.noTile;
      return Tile(256, 256, Uint8List.fromList(data));
    } on DioException {
      return TileProvider.noTile;
    }
  }
}