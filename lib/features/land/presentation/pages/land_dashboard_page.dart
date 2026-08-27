import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/land_state.dart';
import '../../land_provider.dart';
import '../widgets/land_summary_card.dart';
import '../widgets/satellite_status_card.dart';

class LandDashboardPage extends ConsumerStatefulWidget {
  const LandDashboardPage({super.key});
  @override
  ConsumerState<LandDashboardPage> createState() => _LandDashboardPageState();
}

class _LandDashboardPageState extends ConsumerState<LandDashboardPage> {
  @override
  void initState() { super.initState(); Future.microtask(() => ref.read(landProvider.notifier).bootstrap()); }
  @override
  Widget build(BuildContext context) {
    ref.listen(landProvider, (_, next) { if (next.status == LandStatus.noLand) context.go('/land/select'); });
    final state = ref.watch(landProvider);
    final land = state.land;
    if (land == null) return const Center(child: CircularProgressIndicator());
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.horizontalSpacing),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 40),
        Text('SATELLITE MONITORING', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Text('Your Land', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppTheme.primary)),
        const SizedBox(height: 24),
        LandSummaryCard(land: land, isCached: state.isStale),
        const SizedBox(height: 16),
        SatelliteStatusCard(observation: land.latestObservation, policy: state.refreshPolicy, isRefreshing: state.status == LandStatus.refreshing, onRefresh: () => ref.read(landProvider.notifier).refreshSatellite()),
        if (state.message != null) Padding(padding: const EdgeInsets.only(top: 16), child: Text(state.message!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.secondary))),
        const SizedBox(height: 120),
      ]),
    );
  }
}
