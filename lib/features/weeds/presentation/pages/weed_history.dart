import 'package:agribotics/shared/widgets/shared_timeline_item.dart';
import 'package:agribotics/core/providers/app_providers.dart';
import 'package:agribotics/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

class WeedDetectionHistory extends ConsumerStatefulWidget {
  const WeedDetectionHistory({super.key});

  @override
  ConsumerState<WeedDetectionHistory> createState() => _WeedDetectionHistoryState();
}

class _WeedDetectionHistoryState extends ConsumerState<WeedDetectionHistory> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(weedJobsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.horizontalSpacing),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DIAGNOSTIC ARCHIVE',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 3.0, color: AppTheme.secondary),
                    ),
                    const SizedBox(height: 8),
                    Text('Detection', style: Theme.of(context).textTheme.displayLarge),
                    Text('History', style: Theme.of(context).textTheme.displayLarge),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: const Icon(LucideIcons.search, color: AppTheme.primary),
                ),
              ],
            ),
            const SizedBox(height: 48),
            const _TotalScansCard(),
            const SizedBox(height: 48),
            const _StatusOverview(),
            const SizedBox(height: 48),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'RECENT ACTIVITY LOG',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 3.0, color: AppTheme.secondary),
              ),
            ),
            const SizedBox(height: 24),
            const _ScansTimeline(),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

class _TotalScansCard extends ConsumerWidget {
  const _TotalScansCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(weedJobsProvider);
    return jobsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text(error.toString()),
      data: (jobs) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(32)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL SCANS',
                  style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2.0),
                ),
                const SizedBox(height: 24),
                Text(
                  jobs.length.toString(),
                  style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Across all active sectors.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            const Icon(LucideIcons.camera, color: Colors.white24, size: 80),
          ],
        ),
      ),
    );
  }
}

class _StatusOverview extends ConsumerWidget {
  const _StatusOverview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(weedJobsProvider);
    return jobsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text(error.toString()),
      data: (jobs) {
        final completed = jobs.where((j) => j['status'] == 'COMPLETED').length;
        final pending = jobs.where((j) => j['status'] == 'QUEUED' || j['status'] == 'PROCESSING').length;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'COMPLETED',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            completed.toString(),
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.primary),
                          ),
                          const SizedBox(width: 8),
                          Icon(LucideIcons.checkCircle, color: Colors.green.shade400, size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
                VerticalDivider(
                  color: AppTheme.outline.withOpacity(0.2),
                  thickness: 1,
                  indent: 10,
                  endIndent: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'PENDING ANALYSIS',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            pending.toString(),
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.onSurface),
                          ),
                          const SizedBox(width: 8),
                          Icon(LucideIcons.clock, color: Colors.orange.shade400, size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ScansTimeline extends ConsumerWidget {
  const _ScansTimeline();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(weedJobsProvider);
    return jobsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text(error.toString()),
      data: (jobs) {
        if (jobs.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(24)),
            child: const Column(
              children: [
                Icon(LucideIcons.camera, color: AppTheme.onSurfaceVariant, size: 36),
                SizedBox(height: 16),
                Text(
                  'NO DETECTIONS YET',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
                SizedBox(height: 8),
                Text(
                  'Completed weed scans will appear here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant),
                ),
              ],
            ),
          );
        }
        return Column(
          children: jobs.asMap().entries.map((entry) {
            final index = entry.key;
            final job = entry.value;
            final status = job['status']?.toString() ?? 'UNKNOWN';
            final jobId = job['jobId']?.toString() ?? '';
            return SharedTimelineItem(
              isFirst: index == 0,
              label: status,
              title: 'Weed Detection',
              subtitle: job['createdAt']?.toString() ?? '',
              metricLabel: 'JOB',
              metricValue: jobId.length >= 6 ? jobId.substring(0, 6) : jobId,
              dotColor: status == 'COMPLETED'
                  ? Colors.green
                  : status == 'FAILED'
                  ? Colors.red
                  : AppTheme.primary,
              isProcessing: status == 'PROCESSING' || status == 'QUEUED',
              useCard: true,
              onTap: status == 'COMPLETED' && jobId.isNotEmpty
                  ? () => context.go('/weed/map/$jobId')
                  : null,
            );
          }).toList(),
        );
      },
    );
  }
}