import 'satellite_models.dart';

enum SatelliteStatus { initial, loading, loaded, refreshing, error }

class SatelliteState {
  const SatelliteState({this.status = SatelliteStatus.initial, this.observation, this.observationStatus, this.refreshPolicy, this.history = const [], this.mapLayers = const [], this.selectedMapLayer, this.isLoadingHistory = false, this.isLoadingMaps = false, this.message});

  final SatelliteStatus status;
  final SatelliteObservation? observation;
  final String? observationStatus;
  final SatelliteRefreshPolicy? refreshPolicy;
  final List<SatelliteObservation> history;
  final List<SatelliteMapLayer> mapLayers;
  final SatelliteMapLayer? selectedMapLayer;
  final bool isLoadingHistory;
  final bool isLoadingMaps;
  final String? message;

  SatelliteState copyWith({SatelliteStatus? status, SatelliteObservation? observation, String? observationStatus, SatelliteRefreshPolicy? refreshPolicy, List<SatelliteObservation>? history, List<SatelliteMapLayer>? mapLayers, SatelliteMapLayer? selectedMapLayer, bool? isLoadingHistory, bool? isLoadingMaps, String? message}) => SatelliteState(status: status ?? this.status, observation: observation ?? this.observation, observationStatus: observationStatus ?? this.observationStatus, refreshPolicy: refreshPolicy ?? this.refreshPolicy, history: history ?? this.history, mapLayers: mapLayers ?? this.mapLayers, selectedMapLayer: selectedMapLayer ?? this.selectedMapLayer, isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory, isLoadingMaps: isLoadingMaps ?? this.isLoadingMaps, message: message);
}