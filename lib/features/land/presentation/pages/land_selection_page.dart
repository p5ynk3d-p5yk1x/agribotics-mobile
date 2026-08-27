import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart' as permissions;

import '../../../../core/theme/app_theme.dart';
import '../../data/land_models.dart';
import '../../data/land_state.dart';
import '../../land_provider.dart';
import '../widgets/land_map.dart';

class LandSelectionPage extends ConsumerStatefulWidget {
  const LandSelectionPage({super.key});
  @override
  ConsumerState<LandSelectionPage> createState() => _LandSelectionPageState();
}

class _LandSelectionPageState extends ConsumerState<LandSelectionPage> {
  final _vertices = <LatLng>[];
  LatLng? _center;
  GoogleMapController? _controller;
  String? _locationMessage;

  @override
  void initState() { super.initState(); _locateUser(); }

  Future<void> _locateUser() async {
    setState(() => _locationMessage = 'Checking location permission…');
    if (!await Geolocator.isLocationServiceEnabled()) { setState(() => _locationMessage = 'Location services are disabled. Enable GPS to center the map.'); return; }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) { setState(() => _locationMessage = 'Location permission denied. You can still mark land after enabling permission.'); return; }
    if (permission == LocationPermission.deniedForever) { setState(() => _locationMessage = 'Location permission is permanently denied. Open settings to recover.'); return; }
    try {
      final position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 12)));
      final current = LatLng(position.latitude, position.longitude);
      setState(() { _center = current; _locationMessage = null; });
      await _controller?.animateCamera(CameraUpdate.newLatLngZoom(current, 16));
    } catch (_) {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) setState(() => _center = LatLng(last.latitude, last.longitude));
      setState(() => _locationMessage = 'Unable to refresh GPS. Showing last known/default map area.');
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(landProvider, (previous, next) {
      if (next.status == LandStatus.loaded && previous?.status == LandStatus.saving) context.go('/dashboard');
    });
    final state = ref.watch(landProvider);
    final validation = GeoJsonPolygon(_vertices).validate();
    final center = _center ?? const LatLng(21.1458, 79.0882);
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(children: [
        LandMap(initialPosition: center, vertices: _vertices, onMapCreated: (c) => _controller = c, onTap: (point) => setState(() => _vertices.add(point))),
        SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
          _InstructionCard(message: state.message ?? _locationMessage, count: _vertices.length, validation: validation),
          const Spacer(),
          Row(children: [
            _ActionButton(label: 'UNDO', icon: LucideIcons.undo2, onTap: _vertices.isEmpty ? null : () => setState(() => _vertices.removeLast())),
            const SizedBox(width: 10),
            _ActionButton(label: 'CLEAR', icon: LucideIcons.trash2, onTap: _vertices.isEmpty ? null : () => setState(_vertices.clear)),
            const SizedBox(width: 10),
            _ActionButton(label: 'GPS', icon: LucideIcons.locateFixed, onTap: _locateUser),
          ]),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: state.status == LandStatus.saving ? null : () => ref.read(landProvider.notifier).saveLand(_vertices),
            icon: state.status == LandStatus.saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(LucideIcons.check),
            label: const Text('SAVE LAND'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 58), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
          ),
          if (_locationMessage?.contains('permanently') == true) TextButton(onPressed: permissions.openAppSettings, child: const Text('Open device settings')),
        ]))),
      ]),
    );
  }
}

class _InstructionCard extends StatelessWidget {
  const _InstructionCard({required this.count, required this.validation, this.message});
  final int count; final PolygonValidationResult validation; final String? message;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 30)]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('MARK LAND BOUNDARY', style: Theme.of(context).textTheme.labelLarge), const SizedBox(height: 8), Text('Tap the map to place vertices. The app closes the polygon automatically.', style: Theme.of(context).textTheme.bodyMedium), const SizedBox(height: 12), Text('$count points selected', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.primary)), if (message != null || !validation.isValid) Padding(padding: const EdgeInsets.only(top: 8), child: Text(message ?? validation.message!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.error)))]));
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.icon, this.onTap});
  final String label; final IconData icon; final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Expanded(child: OutlinedButton.icon(onPressed: onTap, icon: Icon(icon, size: 16), label: Text(label), style: OutlinedButton.styleFrom(backgroundColor: AppTheme.surface, foregroundColor: AppTheme.primary, side: BorderSide(color: AppTheme.outline.withOpacity(0.2)), padding: const EdgeInsets.symmetric(vertical: 14))));
}
