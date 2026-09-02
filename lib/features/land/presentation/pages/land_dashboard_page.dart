import 'package:agribotics/core/localization/localized_text.dart';
import 'package:agribotics/core/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/land_models.dart';
import '../../data/land_provider.dart';
import '../../data/land_state.dart';
import '../../satellite/data/satellite_models.dart';
import '../../satellite/data/satellite_state.dart';
import '../../satellite/data/satellite_tile_provider.dart';
import '../../satellite/data/satellite_provider.dart';
import '../../weather/presentation/widgets/land_weather_card.dart';
import '../../weather/data/weather_provider.dart';
import 'package:agribotics/l10n/app_localizations.dart';

class LandDashboardPage extends ConsumerStatefulWidget {
  const LandDashboardPage({super.key});

  @override
  ConsumerState<LandDashboardPage> createState() => _LandDashboardPageState();
}

class _LandDashboardPageState extends ConsumerState<LandDashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_bootstrap);
  }

  Future<void> _bootstrap() async {
    await ref.read(landProvider.notifier).bootstrap();
    if (!mounted) return;
    final landState = ref.read(landProvider);
    final land = landState.land;
    if (landState.status != LandStatus.loaded || land == null) return;
    await Future.wait([
      ref.read(satelliteProvider.notifier).bootstrap(),
      ref.read(weatherProvider.notifier).load(latitude: land.centroid.latitude, longitude: land.centroid.longitude),
    ]);
    if (!mounted) return;
    await Future.wait([
      ref.read(satelliteProvider.notifier).loadHistory(),
      ref.read(satelliteProvider.notifier).loadMapLayers(),
    ]);
  }

  Future<void> _retry() async {
    await _bootstrap();
  }

  Future<void> _refreshWeather(Land land) async {
    await ref.read(weatherProvider.notifier).refresh(latitude: land.centroid.latitude, longitude: land.centroid.longitude);
  }

  Future<void> _refreshSatellite() async {
    await ref.read(satelliteProvider.notifier).refresh();
    if (!mounted) return;
    final satelliteState = ref.read(satelliteProvider);
    if (satelliteState.status != SatelliteStatus.loaded) return;
    await Future.wait([
      ref.read(satelliteProvider.notifier).loadHistory(),
      ref.read(satelliteProvider.notifier).loadMapLayers(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ref.listen(landProvider, (previous, next) {
      if (next.status == LandStatus.noLand) context.go('/land/select');
    });
    final landState = ref.watch(landProvider);
    final satelliteState = ref.watch(satelliteProvider);
    final weatherState = ref.watch(weatherProvider);
    if (landState.status == LandStatus.initial || landState.status == LandStatus.loading) return Center(child: CircularProgressIndicator());
    if (landState.status == LandStatus.error && landState.land == null) return _LandLoadError(message: landState.message ?? l10n.landUnableToLoad, onRetry: _retry);
    final land = landState.land;
    if (land == null) return Center(child: CircularProgressIndicator());
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppTheme.horizontalSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text(trText(l10n.landSatelliteMonitoring), style: Theme.of(context).textTheme.labelLarge),
          SizedBox(height: 8),
          Text(trText(l10n.landYourLand), style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppTheme.primary)),
          SizedBox(height: 16),
          LandWeatherCard(state: weatherState, onRefresh: () => _refreshWeather(land)),
          SizedBox(height: 24),
          _SatelliteLayerSelector(state: satelliteState),
          SizedBox(height: 16),
          _LandBoundaryMap(land: land, satelliteState: satelliteState),
          SizedBox(height: 24),
          _SatelliteHeader(state: satelliteState, onRefresh: _refreshSatellite),
          SizedBox(height: 16),
          _SatelliteIndicesSection(state: satelliteState),
          SizedBox(height: 16),
          _SatelliteHistorySection(state: satelliteState),
          if (landState.message != null) Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text(trText(landState.message!), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.secondary)),
          ),
          if (satelliteState.message != null) Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text(trText(satelliteState.message!), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.secondary)),
          ),
          SizedBox(height: 120),
        ],
      ),
    );
  }
}

class _LandBoundaryMap extends ConsumerStatefulWidget {
  const _LandBoundaryMap({required this.land, required this.satelliteState});

  final Land land;
  final SatelliteState satelliteState;

  @override
  ConsumerState<_LandBoundaryMap> createState() => _LandBoundaryMapState();
}

class _LandBoundaryMapState extends ConsumerState<_LandBoundaryMap> {
  GoogleMapController? _controller;

  @override
  Widget build(BuildContext context) {
    final polygon = widget.land.polygon;
    final center = widget.land.centroid;
    final selectedLayer = widget.satelliteState.selectedMapLayer;
    final observation = widget.satelliteState.observation;
    final dio = ref.watch(dioProvider);
    if (polygon.length < 3) return _LandMapUnavailable();
    final tileOverlays = <TileOverlay>{};
    if (selectedLayer != null && observation != null) {
      final version = observation.retrievedAt.millisecondsSinceEpoch;
      tileOverlays.add(
        TileOverlay(
          tileOverlayId: TileOverlayId('${selectedLayer.id}-$version'),
          tileProvider: SatelliteTileProvider(dio, selectedLayer.id),
          transparency: 0.12,
          zIndex: 1,
        ),
      );
    }
    return Container(
      width: double.infinity,
      height: 330,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outline.withOpacity(0.10)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(target: center, zoom: 17),
                mapType: MapType.hybrid,
                myLocationButtonEnabled: false,
                myLocationEnabled: false,
                compassEnabled: true,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                tileOverlays: tileOverlays,
                polygons: {
                  Polygon(
                    polygonId: PolygonId('registered-land'),
                    points: polygon,
                    strokeWidth: 3,
                    strokeColor: AppTheme.primary,
                    fillColor: selectedLayer == null ? AppTheme.primary.withOpacity(0.18) : Colors.transparent,
                    zIndex: 2,
                  ),
                },
                markers: {
                  Marker(
                    markerId: MarkerId('land-centroid'),
                    position: center,
                    infoWindow: InfoWindow(title: trText('Land Center')),
                  ),
                },
                onMapCreated: (controller) {
                  _controller = controller;
                  _fitPolygon(polygon);
                },
              ),
            ),
            Positioned(top: 14, left: 14, child: _MapLabel(selectedLayer: selectedLayer)),
            if (widget.satelliteState.isLoadingMaps) Positioned(top: 14, right: 14, child: _MapLoadingIndicator()),
          ],
        ),
      ),
    );
  }

  Future<void> _fitPolygon(List<LatLng> points) async {
    if (_controller == null || points.isEmpty) return;
    await Future.delayed(Duration(milliseconds: 300));
    if (!mounted) return;
    await _controller!.animateCamera(CameraUpdate.newLatLngBounds(_calculateBounds(points), 55));
  }
}

class _MapLabel extends StatelessWidget {
  const _MapLabel({required this.selectedLayer});

  final SatelliteMapLayer? selectedLayer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.92),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 12)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(selectedLayer == null ? LucideIcons.mapPin : LucideIcons.layers, size: 15, color: AppTheme.primary),
          SizedBox(width: 6),
          Text(trText(selectedLayer?.name.toUpperCase() ?? 'REGISTERED LAND'), style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _MapLoadingIndicator extends StatelessWidget {
  const _MapLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      padding: EdgeInsets.all(9),
      decoration: BoxDecoration(color: AppTheme.surface.withOpacity(0.92), borderRadius: BorderRadius.circular(12)),
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }
}

class _SatelliteHeader extends StatelessWidget {
  const _SatelliteHeader({required this.state, required this.onRefresh});

  final SatelliteState state;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final observation = state.observation;
    final policy = state.refreshPolicy;
    final isRefreshing = state.status == SatelliteStatus.refreshing;
    final canRefresh = policy?.refreshAllowed == true && !isRefreshing;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.10), borderRadius: BorderRadius.circular(14)),
                child: Icon(LucideIcons.satellite, size: 20, color: AppTheme.primary),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trText('SATELLITE STATUS'), style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
                    SizedBox(height: 3),
                    Text(trText(_statusLabel(state)), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.secondary)),
                  ],
                ),
              ),
              _StatusDot(active: observation != null),
            ],
          ),
          SizedBox(height: 18),
          if (state.status == SatelliteStatus.loading) Center(child: CircularProgressIndicator()),
          if (state.status != SatelliteStatus.loading) Row(
            children: [
              Expanded(child: _InfoItem(label: 'DATASET', value: observation?.dataset ?? 'Waiting for data')),
              SizedBox(width: 12),
              Expanded(child: _InfoItem(label: 'CLOUD COVER', value: observation?.cloudPercentage == null ? '—' : '${observation!.cloudPercentage!.toStringAsFixed(1)}%')),
            ],
          ),
          if (observation != null) SizedBox(height: 14),
          if (observation != null) Row(
            children: [
              Expanded(child: _InfoItem(label: 'OBSERVED', value: _formatDateTime(observation.observationTime))),
              SizedBox(width: 12),
              Expanded(child: _InfoItem(label: 'RETRIEVED', value: _formatDateTime(observation.retrievedAt))),
            ],
          ),
          if (policy != null) SizedBox(height: 18),
          if (policy != null) _RefreshInfo(policy: policy),
          SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: canRefresh ? onRefresh : null,
              icon: isRefreshing ? SizedBox(width: 17, height: 17, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(LucideIcons.refreshCw, size: 18),
              label: Text(trText(isRefreshing ? 'REFRESHING...' : policy?.refreshAllowed == true ? 'REFRESH SATELLITE' : 'REFRESH NOT AVAILABLE')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.primary.withOpacity(0.40),
                disabledForegroundColor: Colors.white,
                elevation: 0,
                minimumSize: Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SatelliteIndicesSection extends StatelessWidget {
  const _SatelliteIndicesSection({required this.state});

  final SatelliteState state;

  @override
  Widget build(BuildContext context) {
    final observation = state.observation;
    if (state.status == SatelliteStatus.loading) return SizedBox.shrink();
    if (observation == null) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Icon(LucideIcons.activity, color: AppTheme.outline),
            SizedBox(width: 12),
            Expanded(child: Text(trText('Vegetation indices will appear when a usable satellite observation becomes available.'), style: Theme.of(context).textTheme.bodyMedium)),
          ],
        ),
      );
    }
    final indices = observation.indices;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(trText('VEGETATION INDICES'), style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _IndexCard(label: 'NDVI', value: indices.ndvi, description: 'Vegetation')),
            SizedBox(width: 10),
            Expanded(child: _IndexCard(label: 'NDMI', value: indices.ndmi, description: 'Moisture')),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _IndexCard(label: 'NDWI', value: indices.ndwi, description: 'Water')),
            SizedBox(width: 10),
            Expanded(child: _IndexCard(label: 'EVI', value: indices.evi, description: 'Enhanced vegetation')),
          ],
        ),
        SizedBox(height: 10),
        _IndexCard(label: 'SAVI', value: indices.savi, description: 'Soil adjusted'),
      ],
    );
  }
}

class _SatelliteLayerSelector extends ConsumerWidget {
  const _SatelliteLayerSelector({required this.state});

  final SatelliteState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoadingMaps && state.mapLayers.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: _cardDecoration(),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.mapLayers.isEmpty) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(trText('SATELLITE MAP'), style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
        SizedBox(height: 6),
        Text(trText('Choose how Earth Engine visualizes your registered land.'), style: Theme.of(context).textTheme.bodyMedium),
        SizedBox(height: 12),
        Row(
          children: [
            for (var i = 0; i < state.mapLayers.length; i++) ...[
              if (i > 0) SizedBox(width: 10),
              Expanded(child: _LayerButton(layer: state.mapLayers[i], selected: state.selectedMapLayer?.id == state.mapLayers[i].id, onTap: () => ref.read(satelliteProvider.notifier).selectMapLayer(state.mapLayers[i].id))),
            ],
          ],
        ),
        if (state.selectedMapLayer != null) SizedBox(height: 10),
        if (state.selectedMapLayer != null) Text(trText(state.selectedMapLayer!.description), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.secondary)),
      ],
    );
  }
}

class _SatelliteHistorySection extends StatelessWidget {
  const _SatelliteHistorySection({required this.state});

  final SatelliteState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingHistory && state.history.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: _cardDecoration(),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.history.isEmpty) return SizedBox.shrink();
    final observations = state.history.take(3).toList();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.history, size: 19, color: AppTheme.primary),
              SizedBox(width: 9),
              Text(trText('RECENT OBSERVATIONS'), style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          SizedBox(height: 16),
          for (var i = 0; i < observations.length; i++) ...[
            _HistoryRow(observation: observations[i]),
            if (i < observations.length - 1) Divider(height: 22, color: AppTheme.outline.withOpacity(0.10)),
          ],
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.observation});

  final SatelliteObservation observation;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(trText(_formatDateTime(observation.observationTime)), style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              SizedBox(height: 3),
              Text(trText(observation.dataset), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.secondary)),
            ],
          ),
        ),
        _HistoryValue(label: 'NDVI', value: observation.indices.ndvi),
        SizedBox(width: 18),
        _HistoryValue(label: 'NDMI', value: observation.indices.ndmi),
      ],
    );
  }
}

class _HistoryValue extends StatelessWidget {
  const _HistoryValue({required this.label, required this.value});

  final String label;
  final double? value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(trText(label), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.secondary)),
        SizedBox(height: 2),
        Text(trText(value?.toStringAsFixed(2) ?? '—'), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _IndexCard extends StatelessWidget {
  const _IndexCard({required this.label, required this.value, required this.description});

  final String label;
  final double? value;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 96),
      padding: EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(trText(label), style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.primary, fontWeight: FontWeight.w700)),
          SizedBox(height: 6),
          Text(trText(value?.toStringAsFixed(3) ?? '—'), style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          SizedBox(height: 3),
          Text(trText(description), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.secondary)),
        ],
      ),
    );
  }
}

class _LayerButton extends StatelessWidget {
  const _LayerButton({required this.layer, required this.selected, required this.onTap});

  final SatelliteMapLayer layer;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? AppTheme.primary.withOpacity(0.10) : AppTheme.surface,
        foregroundColor: AppTheme.primary,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        side: BorderSide(color: selected ? AppTheme.primary : AppTheme.outline.withOpacity(0.15)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(trText(layer.name.toUpperCase()), textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700)),
    );
  }
}

class _RefreshInfo extends StatelessWidget {
  const _RefreshInfo({required this.policy});

  final SatelliteRefreshPolicy policy;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          _RefreshRow(label: 'Last successful', value: policy.lastQueriedAt == null ? 'No successful query yet' : _formatDateTime(policy.lastQueriedAt!)),
          SizedBox(height: 8),
          _RefreshRow(label: 'Last attempted', value: policy.lastAttemptedAt == null ? 'No attempt yet' : _formatDateTime(policy.lastAttemptedAt!)),
          SizedBox(height: 8),
          _RefreshRow(label: 'Next refresh', value: _formatDateTime(policy.nextRefreshAt)),
        ],
      ),
    );
  }
}

class _RefreshRow extends StatelessWidget {
  const _RefreshRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          trText(label),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.secondary,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            trText(value),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(trText(label), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.secondary)),
        SizedBox(height: 4),
        Text(trText(value), style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(width: 10, height: 10, decoration: BoxDecoration(color: active ? AppTheme.primary : AppTheme.outline, shape: BoxShape.circle));
  }
}

class _LandMapUnavailable extends StatelessWidget {
  const _LandMapUnavailable();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outline.withOpacity(0.10)),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.map, size: 28, color: AppTheme.outline),
            SizedBox(height: 10),
            Text(trText('Land boundary unavailable'), style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _LandLoadError extends StatelessWidget {
  const _LandLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppTheme.horizontalSpacing),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(trText('Unable to load land'), style: Theme.of(context).textTheme.headlineSmall),
            SizedBox(height: 8),
            Text(trText(message), textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
            SizedBox(height: 20),
            ElevatedButton(onPressed: onRetry, child: Text(trText('RETRY'))),
          ],
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: AppTheme.surface,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppTheme.outline.withOpacity(0.10)),
    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.035), blurRadius: 20, offset: Offset(0, 7))],
  );
}

String _statusLabel(SatelliteState state) {
  if (state.status == SatelliteStatus.loading) return 'Loading satellite information';
  if (state.status == SatelliteStatus.refreshing) return 'Refreshing satellite observation';
  if (state.observationStatus == 'SUCCESS') return 'Latest observation available';
  if (state.observationStatus == 'NO_DATA') return 'No usable satellite data available';
  if (state.observationStatus == 'TEMPORARILY_UNAVAILABLE') return 'Satellite service temporarily unavailable';
  if (state.observation == null) return 'Waiting for first satellite observation';
  return state.observationStatus ?? 'Satellite monitoring active';
}

String _formatDateTime(DateTime dateTime) {
  final local = dateTime.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month/${local.year} $hour:$minute';
}

LatLngBounds _calculateBounds(List<LatLng> points) {
  var minLatitude = points.first.latitude;
  var maxLatitude = points.first.latitude;
  var minLongitude = points.first.longitude;
  var maxLongitude = points.first.longitude;
  for (final point in points.skip(1)) {
    if (point.latitude < minLatitude) minLatitude = point.latitude;
    if (point.latitude > maxLatitude) maxLatitude = point.latitude;
    if (point.longitude < minLongitude) minLongitude = point.longitude;
    if (point.longitude > maxLongitude) maxLongitude = point.longitude;
  }
  if (minLatitude == maxLatitude) {
    minLatitude -= 0.0001;
    maxLatitude += 0.0001;
  }
  if (minLongitude == maxLongitude) {
    minLongitude -= 0.0001;
    maxLongitude += 0.0001;
  }
  return LatLngBounds(southwest: LatLng(minLatitude, minLongitude), northeast: LatLng(maxLatitude, maxLongitude));
}
