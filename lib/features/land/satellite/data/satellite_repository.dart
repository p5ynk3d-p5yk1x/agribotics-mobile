import 'satellite_api.dart';
import 'satellite_models.dart';

class SatelliteRepository {
  SatelliteRepository(this._api);

  final SatelliteApi _api;

  Future<SatelliteResponse> loadCurrentSatellite() => _api.getCurrentSatellite();
  Future<SatelliteResponse> refreshSatellite() => _api.refreshSatellite();
  Future<List<SatelliteObservation>> loadHistory({int limit = 30}) => _api.getHistory(limit: limit);
  Future<SatelliteMapResponse> loadMapLayers() => _api.getMapLayers();
}