import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/theme/app_theme.dart';

class LandMap extends StatelessWidget {
  const LandMap({super.key, required this.initialPosition, required this.vertices, required this.onTap, required this.onMapCreated});
  final LatLng initialPosition;
  final List<LatLng> vertices;
  final ValueChanged<LatLng> onTap;
  final ValueChanged<GoogleMapController> onMapCreated;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: initialPosition, zoom: 16),
      myLocationButtonEnabled: false,
      myLocationEnabled: true,
      onTap: onTap,
      onMapCreated: onMapCreated,
      markers: {
        for (var i = 0; i < vertices.length; i++) Marker(markerId: MarkerId('vertex_$i'), position: vertices[i], infoWindow: InfoWindow(title: 'Point ${i + 1}')),
      },
      polygons: vertices.length >= 3
          ? {Polygon(polygonId: const PolygonId('selected_land'), points: vertices, strokeColor: AppTheme.primary, fillColor: AppTheme.emerald.withOpacity(0.18), strokeWidth: 3)}
          : {},
    );
  }
}
