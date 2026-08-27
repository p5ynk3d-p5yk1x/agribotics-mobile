import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/land_models.dart';
import 'refresh_countdown.dart';

class SatelliteStatusCard extends StatelessWidget {
  const SatelliteStatusCard({super.key, required this.observation, required this.policy, required this.onRefresh, required this.isRefreshing});
  final SatelliteObservation? observation;
  final SatelliteRefreshPolicy? policy;
  final VoidCallback onRefresh;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) {
    final canRefresh = policy?.refreshAllowed == true && !isRefreshing;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppTheme.surfaceContainerLow, borderRadius: BorderRadius.circular(24)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Icon(LucideIcons.satellite, color: AppTheme.primary), const SizedBox(width: 12), Text('SATELLITE DATA', style: Theme.of(context).textTheme.labelLarge)]),
        const SizedBox(height: 18),
        Text(observation?.status ?? 'LATEST OBSERVATION', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        Text('NDVI ${observation?.ndvi?.toStringAsFixed(2) ?? '—'} • Cloud ${observation?.cloudPercentage?.toStringAsFixed(0) ?? '—'}%', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 8),
        Text('Observed ${_fmt(observation?.observationTime)} • Last satellite sync ${_fmt(policy?.lastQueriedAt)}', style: Theme.of(context).textTheme.bodyMedium),
        if (policy?.refreshAllowed == false) ...[const SizedBox(height: 8), RefreshCountdown(nextRefreshAt: policy?.nextRefreshAt)],
        const SizedBox(height: 20),
        ElevatedButton.icon(onPressed: canRefresh ? onRefresh : null, icon: isRefreshing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(LucideIcons.refreshCw), label: Text(canRefresh ? 'REFRESH SATELLITE' : 'REFRESH LOCKED'), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 52))),
      ]),
    );
  }

  String _fmt(DateTime? value) => value == null ? '—' : DateFormat('MMM d, HH:mm').format(value.toLocal());
}
