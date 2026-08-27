import 'land_models.dart';

enum LandStatus { initial, checkingLocalState, loadingExistingLand, noLand, requestingLocation, selecting, validating, saving, loaded, refreshing, error }

class LandState {
  const LandState({this.status = LandStatus.initial, this.land, this.refreshPolicy, this.message, this.isStale = false});
  final LandStatus status;
  final Land? land;
  final SatelliteRefreshPolicy? refreshPolicy;
  final String? message;
  final bool isStale;
  LandState copyWith({LandStatus? status, Land? land, SatelliteRefreshPolicy? refreshPolicy, String? message, bool? isStale}) => LandState(status: status ?? this.status, land: land ?? this.land, refreshPolicy: refreshPolicy ?? this.refreshPolicy, message: message, isStale: isStale ?? this.isStale);
}
