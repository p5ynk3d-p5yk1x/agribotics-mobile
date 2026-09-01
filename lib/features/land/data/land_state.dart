import 'land_models.dart';

enum LandStatus { initial, loading, noLand, selecting, saving, loaded, deleting, error }

class LandState {
  const LandState({this.status = LandStatus.initial, this.land, this.message, this.isStale = false});

  final LandStatus status;
  final Land? land;
  final String? message;
  final bool isStale;

  LandState copyWith({LandStatus? status, Land? land, String? message, bool? isStale}) => LandState(status: status ?? this.status, land: land ?? this.land, message: message, isStale: isStale ?? this.isStale);
}