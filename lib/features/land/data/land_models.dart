import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeoJsonPolygon {
  GeoJsonPolygon(this.vertices);

  static const int maxVertices = 200;
  final List<LatLng> vertices;

  Map<String, dynamic> toGeometryJson() {
    final ring = vertices.map((point) => [point.longitude, point.latitude]).toList(growable: true);
    if (ring.isNotEmpty) ring.add([vertices.first.longitude, vertices.first.latitude]);
    return {'type': 'Polygon', 'coordinates': [ring]};
  }

  Map<String, dynamic> toFeatureJson() => {'type': 'Feature', 'properties': <String, dynamic>{}, 'geometry': toGeometryJson()};

  PolygonValidationResult validate() {
    if (vertices.length < 3) return const PolygonValidationResult.invalid('Add at least 3 boundary points.');
    if (vertices.length > maxVertices) return const PolygonValidationResult.invalid('Use fewer than 200 boundary points.');

    for (final point in vertices) {
      if (!point.latitude.isFinite || !point.longitude.isFinite) return const PolygonValidationResult.invalid('Coordinates must be valid numbers.');
      if (point.latitude < -90 || point.latitude > 90) return const PolygonValidationResult.invalid('Latitude is outside the valid range.');
      if (point.longitude < -180 || point.longitude > 180) return const PolygonValidationResult.invalid('Longitude is outside the valid range.');
    }

    final distinct = <String>{};

    for (final point in vertices) {
      distinct.add('${point.latitude.toStringAsFixed(7)},${point.longitude.toStringAsFixed(7)}');
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
    final value = (q.latitude - p.latitude) * (r.longitude - q.longitude) - (q.longitude - p.longitude) * (r.latitude - q.latitude);
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
  LandResponse({required this.land});

  final Land land;

  factory LandResponse.fromJson(Map<String, dynamic> json) {
    final landJson = json['land'];
    if (landJson is! Map<String, dynamic>) throw const FormatException('Land response does not contain a valid land object.');
    return LandResponse(land: Land.fromJson(landJson));
  }
}

class Land {
  Land({required this.landId, required this.areaSqMeters, required this.centroid, required this.polygon});

  final String landId;
  final double areaSqMeters;
  final LatLng centroid;
  final List<LatLng> polygon;

  double get areaHectares => areaSqMeters / 10000;

  factory Land.fromJson(Map<String, dynamic> json) {
    final landId = json['id'] ?? json['_id'] ?? json['landId'];
    final areaSqMeters = _double(json['areaSqMeters']);
    final centroid = _latLng(json['centroid']);
    final polygon = _polygon(json['geometry']);

    if (landId == null || landId.toString().isEmpty) throw const FormatException('Land ID is missing.');
    if (areaSqMeters == null) throw const FormatException('Land area is missing.');
    if (centroid == null) throw const FormatException('Land centroid is missing.');
    if (polygon.length < 3) throw const FormatException('Land polygon is invalid.');

    return Land(landId: landId.toString(), areaSqMeters: areaSqMeters, centroid: centroid, polygon: polygon);
  }
}

double? _double(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

LatLng? _latLng(Object? value) {
  if (value is! Map) return null;
  final coordinates = value['coordinates'];

  if (coordinates is List && coordinates.length >= 2) {
    final longitude = _double(coordinates[0]);
    final latitude = _double(coordinates[1]);
    if (latitude != null && longitude != null) return LatLng(latitude, longitude);
  }

  return null;
}

List<LatLng> _polygon(Object? value) {
  if (value is! Map) return const [];
  final coordinates = value['coordinates'];
  if (coordinates is! List || coordinates.isEmpty || coordinates.first is! List) return const [];

  final ring = coordinates.first as List;
  final points = <LatLng>[];

  for (final coordinate in ring) {
    if (coordinate is! List || coordinate.length < 2) continue;
    final longitude = _double(coordinate[0]);
    final latitude = _double(coordinate[1]);
    if (latitude == null || longitude == null) continue;
    points.add(LatLng(latitude, longitude));
  }

  if (points.length > 1 && points.first.latitude == points.last.latitude && points.first.longitude == points.last.longitude) points.removeLast();

  return points;
}