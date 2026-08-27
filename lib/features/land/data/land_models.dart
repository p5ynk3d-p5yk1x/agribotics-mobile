import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeoJsonPolygon {
  GeoJsonPolygon(this.vertices);

  static const int maxVertices = 200;
  final List<LatLng> vertices;

  Map<String, dynamic> toFeatureJson() {
    final ring = vertices
        .map((point) => [point.longitude, point.latitude])
        .toList(growable: true);
    if (ring.isNotEmpty) {
      ring.add([vertices.first.longitude, vertices.first.latitude]);
    }
    return {
      'type': 'Feature',
      'properties': <String, dynamic>{},
      'geometry': {
        'type': 'Polygon',
        'coordinates': [ring],
      },
    };
  }

  PolygonValidationResult validate() {
    if (vertices.length < 3) return const PolygonValidationResult.invalid('Add at least 3 boundary points.');
    if (vertices.length > maxVertices) return const PolygonValidationResult.invalid('Use fewer than 200 boundary points.');
    for (final p in vertices) {
      if (!p.latitude.isFinite || !p.longitude.isFinite) return const PolygonValidationResult.invalid('Coordinates must be valid numbers.');
      if (p.latitude < -90 || p.latitude > 90) return const PolygonValidationResult.invalid('Latitude is outside the valid range.');
      if (p.longitude < -180 || p.longitude > 180) return const PolygonValidationResult.invalid('Longitude is outside the valid range.');
    }
    final distinct = <String>{};
    for (final p in vertices) {
      distinct.add('${p.latitude.toStringAsFixed(7)},${p.longitude.toStringAsFixed(7)}');
    }
    if (distinct.length < 3) return const PolygonValidationResult.invalid('Add 3 distinct boundary points.');
    if (_signedArea(vertices).abs() < 0.000000000001) return const PolygonValidationResult.invalid('Boundary area is too small.');
    if (_selfIntersects(vertices)) return const PolygonValidationResult.invalid('Boundary lines cannot cross each other.');
    return const PolygonValidationResult.valid();
  }

  static double _signedArea(List<LatLng> points) {
    var sum = 0.0;
    for (var i = 0; i < points.length; i++) {
      final a = points[i];
      final b = points[(i + 1) % points.length];
      sum += a.longitude * b.latitude - b.longitude * a.latitude;
    }
    return sum / 2;
  }

  static bool _selfIntersects(List<LatLng> points) {
    for (var i = 0; i < points.length; i++) {
      final a1 = points[i];
      final a2 = points[(i + 1) % points.length];
      for (var j = i + 1; j < points.length; j++) {
        if ((i - j).abs() <= 1 || (i == 0 && j == points.length - 1)) continue;
        final b1 = points[j];
        final b2 = points[(j + 1) % points.length];
        if (_segmentsIntersect(a1, a2, b1, b2)) return true;
      }
    }
    return false;
  }

  static bool _segmentsIntersect(LatLng p1, LatLng q1, LatLng p2, LatLng q2) {
    final o1 = _orientation(p1, q1, p2);
    final o2 = _orientation(p1, q1, q2);
    final o3 = _orientation(p2, q2, p1);
    final o4 = _orientation(p2, q2, q1);
    return o1 != o2 && o3 != o4;
  }

  static int _orientation(LatLng p, LatLng q, LatLng r) {
    final value = (q.latitude - p.latitude) * (r.longitude - q.longitude) -
        (q.longitude - p.longitude) * (r.latitude - q.latitude);
    if (value.abs() < pow(10, -12)) return 0;
    return value > 0 ? 1 : 2;
  }
}

class PolygonValidationResult {
  const PolygonValidationResult.valid() : isValid = true, message = null;
  const PolygonValidationResult.invalid(this.message) : isValid = false;
  final bool isValid;
  final String? message;
}

class LandResponse {
  LandResponse({required this.land, required this.refreshPolicy});
  final Land land;
  final SatelliteRefreshPolicy refreshPolicy;
  factory LandResponse.fromJson(Map<String, dynamic> json) => LandResponse(
        land: Land.fromJson((json['land'] ?? json) as Map<String, dynamic>),
        refreshPolicy: SatelliteRefreshPolicy.fromJson((json['refreshPolicy'] ?? json) as Map<String, dynamic>),
      );
}

class Land {
  Land({required this.landId, this.areaHectares, this.centroid, this.polygon = const [], this.createdAt, this.updatedAt, this.latestObservation});
  final String landId;
  final double? areaHectares;
  final LatLng? centroid;
  final List<LatLng> polygon;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final SatelliteObservation? latestObservation;
  factory Land.fromJson(Map<String, dynamic> json) => Land(
        landId: (json['landId'] ?? json['id'] ?? json['_id']).toString(),
        areaHectares: _double(json['areaHectares'] ?? json['area']),
        centroid: _latLng(json['centroid']),
        polygon: _polygon(json['polygon'] ?? json['geometry']),
        createdAt: _date(json['createdAt']),
        updatedAt: _date(json['updatedAt']),
        latestObservation: json['latestObservation'] is Map<String, dynamic> ? SatelliteObservation.fromJson(json['latestObservation']) : null,
      );
}

class SatelliteObservation {
  SatelliteObservation({this.observationTime, this.retrievedAt, this.ndvi, this.vegetationMetrics = const {}, this.cloudPercentage, this.source, this.status});
  final DateTime? observationTime, retrievedAt;
  final double? ndvi, cloudPercentage;
  final Map<String, dynamic> vegetationMetrics;
  final String? source, status;
  factory SatelliteObservation.fromJson(Map<String, dynamic> json) => SatelliteObservation(
        observationTime: _date(json['observationTime']), retrievedAt: _date(json['retrievedAt']), ndvi: _double(json['ndvi']),
        vegetationMetrics: json['vegetationMetrics'] is Map<String, dynamic> ? json['vegetationMetrics'] as Map<String, dynamic> : const {},
        cloudPercentage: _double(json['cloudPercentage']), source: json['source']?.toString(), status: json['status']?.toString(),
      );
}

class SatelliteRefreshPolicy {
  SatelliteRefreshPolicy({this.lastQueriedAt, this.nextRefreshAt, required this.refreshAllowed});
  final DateTime? lastQueriedAt, nextRefreshAt;
  final bool refreshAllowed;
  factory SatelliteRefreshPolicy.fromJson(Map<String, dynamic> json) => SatelliteRefreshPolicy(
        lastQueriedAt: _date(json['lastQueriedAt']), nextRefreshAt: _date(json['nextRefreshAt']), refreshAllowed: json['refreshAllowed'] == true,
      );
}

double? _double(Object? value) => value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '');
DateTime? _date(Object? value) => value == null ? null : DateTime.tryParse(value.toString());
LatLng? _latLng(Object? value) { if (value is Map) { final lat=_double(value['latitude']??value['lat']); final lng=_double(value['longitude']??value['lng']); if(lat!=null&&lng!=null) return LatLng(lat,lng);} return null; }
List<LatLng> _polygon(Object? value) { final coords = value is Map ? value['coordinates'] : value; if (coords is List && coords.isNotEmpty && coords.first is List) { final ring = coords.first as List; return ring.whereType<List>().map((p)=>p.length>=2?LatLng(_double(p[1])??0,_double(p[0])??0):null).whereType<LatLng>().toList(); } return const []; }
