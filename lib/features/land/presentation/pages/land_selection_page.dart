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
  final List<LatLng> _vertices = [];

  LatLng? _center;
  GoogleMapController? _controller;
  String? _locationMessage;

  @override
  void initState() {
    super.initState();
    _locateUser();
  }

  Future<void> _locateUser() async {
    if (!mounted) return;

    setState(() {
      _locationMessage = 'Checking location permission…';
    });

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (!mounted) return;

      setState(() {
        _locationMessage =
        'Location services are disabled. Enable GPS to center the map.';
      });

      return;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      if (!mounted) return;

      setState(() {
        _locationMessage =
        'Location permission denied. You can still mark land manually.';
      });

      return;
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;

      setState(() {
        _locationMessage =
        'Location permission is permanently denied. Open settings to recover.';
      });

      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );

      final current = LatLng(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      setState(() {
        _center = current;
        _locationMessage = null;
      });

      await _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(
          current,
          16,
        ),
      );
    } catch (_) {
      final last = await Geolocator.getLastKnownPosition();

      if (!mounted) return;

      if (last != null) {
        final lastKnown = LatLng(
          last.latitude,
          last.longitude,
        );

        setState(() {
          _center = lastKnown;
          _locationMessage =
          'Unable to refresh GPS. Showing your last known location.';
        });

        await _controller?.animateCamera(
          CameraUpdate.newLatLngZoom(
            lastKnown,
            16,
          ),
        );
      } else {
        setState(() {
          _locationMessage =
          'Unable to get your location. You can still mark the land manually.';
        });
      }
    }
  }

  void _addVertex(LatLng point) {
    setState(() {
      _vertices.add(point);
    });
  }

  void _undoVertex() {
    if (_vertices.isEmpty) return;

    setState(() {
      _vertices.removeLast();
    });
  }

  void _clearVertices() {
    if (_vertices.isEmpty) return;

    setState(() {
      _vertices.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(landProvider, (previous, next) {
      if (next.status == LandStatus.loaded &&
          previous?.status == LandStatus.saving) {
        context.go('/dashboard');
      }
    });

    final state = ref.watch(landProvider);

    final validation = GeoJsonPolygon(_vertices).validate();

    final center = _center ??
        const LatLng(
          21.1458,
          79.0882,
        );

    final isSaving = state.status == LandStatus.saving;

    final displayMessage = state.message ?? _locationMessage;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Mark Your Land',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            16,
          ),
          child: Column(
            children: [
              _InstructionCard(
                message: displayMessage,
                count: _vertices.length,
                validation: validation,
              ),

              const SizedBox(height: 16),

              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: LandMap(
                          initialPosition: center,
                          vertices: _vertices,
                          onMapCreated: (controller) {
                            _controller = controller;

                            if (_center != null) {
                              controller.animateCamera(
                                CameraUpdate.newLatLngZoom(
                                  _center!,
                                  16,
                                ),
                              );
                            }
                          },
                          onTap: _addVertex,
                        ),
                      ),

                      Positioned(
                        top: 14,
                        right: 14,
                        child: _MapHint(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  _ActionButton(
                    label: 'UNDO',
                    icon: LucideIcons.undo2,
                    onTap: _vertices.isEmpty ? null : _undoVertex,
                  ),
                  const SizedBox(width: 10),
                  _ActionButton(
                    label: 'CLEAR',
                    icon: LucideIcons.trash2,
                    onTap: _vertices.isEmpty ? null : _clearVertices,
                  ),
                  const SizedBox(width: 10),
                  _ActionButton(
                    label: 'GPS',
                    icon: LucideIcons.locateFixed,
                    onTap: _locateUser,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: isSaving
                    ? null
                    : () {
                  ref
                      .read(landProvider.notifier)
                      .saveLand(_vertices);
                },
                icon: isSaving
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(
                  LucideIcons.check,
                  size: 20,
                ),
                label: Text(
                  isSaving ? 'SAVING LAND...' : 'SAVE LAND',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                  AppTheme.primary.withOpacity(0.55),
                  disabledForegroundColor: Colors.white,
                  minimumSize: const Size(
                    double.infinity,
                    58,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),

              if (_locationMessage?.contains('permanently') == true)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: TextButton(
                    onPressed: permissions.openAppSettings,
                    child: const Text(
                      'Open device settings',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstructionCard extends StatelessWidget {
  const _InstructionCard({
    required this.count,
    required this.validation,
    this.message,
  });

  final int count;
  final PolygonValidationResult validation;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final hasError = message != null || !validation.isValid;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.outline.withOpacity(0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  LucideIcons.map,
                  size: 20,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'MARK LAND BOUNDARY',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Text(
                '$count pts',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            'Tap the map to place vertices around your land. '
                'The polygon will close automatically.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.4,
            ),
          ),

          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  message ?? validation.message!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.error,
                    height: 1.35,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MapHint extends StatelessWidget {
  const _MapHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.92),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            LucideIcons.mousePointer2,
            size: 15,
            color: AppTheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            'Tap to mark',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 16,
        ),
        label: Text(
          label,
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: AppTheme.surface,
          foregroundColor: AppTheme.primary,
          disabledForegroundColor:
          AppTheme.outline.withOpacity(0.4),
          side: BorderSide(
            color: AppTheme.outline.withOpacity(0.15),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}