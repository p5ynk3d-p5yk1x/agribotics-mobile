class SatelliteResponse {
  SatelliteResponse({required this.observation, required this.status, required this.refreshPolicy});

  final SatelliteObservation? observation;
  final String? status;
  final SatelliteRefreshPolicy refreshPolicy;

  factory SatelliteResponse.fromJson(Map<String, dynamic> json) {
    final satelliteJson = json['satellite'];
    final refreshJson = json['refresh'];

    return SatelliteResponse(
      observation: satelliteJson is Map<String, dynamic> ? SatelliteObservation.fromJson(satelliteJson) : null,
      status: json['satelliteStatus']?.toString(),
      refreshPolicy: SatelliteRefreshPolicy.fromJson(refreshJson is Map<String, dynamic> ? refreshJson : const {}),
    );
  }
}

class SatelliteObservation {
  SatelliteObservation({required this.observationTime, required this.retrievedAt, required this.dataset, this.cloudPercentage, required this.indices});

  final DateTime observationTime;
  final DateTime retrievedAt;
  final String dataset;
  final double? cloudPercentage;
  final SatelliteIndices indices;

  factory SatelliteObservation.fromJson(Map<String, dynamic> json) {
    final observationTime = _date(json['observationTime']);
    final retrievedAt = _date(json['retrievedAt']);
    final dataset = json['dataset']?.toString();
    final indicesJson = json['indices'];

    if (observationTime == null) throw const FormatException('Satellite observation time is missing.');
    if (retrievedAt == null) throw const FormatException('Satellite retrieval time is missing.');
    if (dataset == null || dataset.isEmpty) throw const FormatException('Satellite dataset is missing.');

    return SatelliteObservation(
      observationTime: observationTime,
      retrievedAt: retrievedAt,
      dataset: dataset,
      cloudPercentage: _double(json['cloudPercentage']),
      indices: SatelliteIndices.fromJson(indicesJson is Map<String, dynamic> ? indicesJson : const {}),
    );
  }
}

class SatelliteIndices {
  SatelliteIndices({this.ndvi, this.ndmi, this.ndwi, this.evi, this.savi});

  final double? ndvi;
  final double? ndmi;
  final double? ndwi;
  final double? evi;
  final double? savi;

  factory SatelliteIndices.fromJson(Map<String, dynamic> json) => SatelliteIndices(ndvi: _double(json['ndvi']), ndmi: _double(json['ndmi']), ndwi: _double(json['ndwi']), evi: _double(json['evi']), savi: _double(json['savi']));
}

class SatelliteRefreshPolicy {
  SatelliteRefreshPolicy({this.lastQueriedAt, this.lastAttemptedAt, required this.nextRefreshAt, required this.refreshAllowed});

  final DateTime? lastQueriedAt;
  final DateTime? lastAttemptedAt;
  final DateTime nextRefreshAt;
  final bool refreshAllowed;

  factory SatelliteRefreshPolicy.fromJson(Map<String, dynamic> json) {
    final nextRefreshAt = _date(json['nextRefreshAt']);
    if (nextRefreshAt == null) throw const FormatException('Satellite refresh time is missing.');

    return SatelliteRefreshPolicy(
      lastQueriedAt: _date(json['lastQueriedAt']),
      lastAttemptedAt: _date(json['lastAttemptedAt']),
      nextRefreshAt: nextRefreshAt,
      refreshAllowed: json['refreshAllowed'] == true,
    );
  }
}

class SatelliteMapResponse {
  SatelliteMapResponse({required this.observationTime, required this.layers});

  final DateTime observationTime;
  final List<SatelliteMapLayer> layers;

  factory SatelliteMapResponse.fromJson(Map<String, dynamic> json) {
    final observationTime = _date(json['observationTime']);
    final layerJson = json['layers'];

    if (observationTime == null) throw const FormatException('Satellite map observation time is missing.');

    return SatelliteMapResponse(
      observationTime: observationTime,
      layers: layerJson is List ? layerJson.whereType<Map<String, dynamic>>().map(SatelliteMapLayer.fromJson).toList() : const [],
    );
  }
}

class SatelliteMapLayer {
  SatelliteMapLayer({required this.id, required this.name, required this.description, required this.tilePath});

  final String id;
  final String name;
  final String description;
  final String tilePath;

  factory SatelliteMapLayer.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString();
    final name = json['name']?.toString();
    final description = json['description']?.toString();
    final tilePath = json['tilePath']?.toString();

    if (id == null || name == null || description == null || tilePath == null) throw const FormatException('Satellite map layer is malformed.');

    return SatelliteMapLayer(id: id, name: name, description: description, tilePath: tilePath);
  }
}

double? _double(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

DateTime? _date(Object? value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}