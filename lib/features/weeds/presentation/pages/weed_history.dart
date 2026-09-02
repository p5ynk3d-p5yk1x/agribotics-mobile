import 'package:agribotics/core/localization/localized_text.dart';
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
        padding: EdgeInsets.symmetric(horizontal: AppTheme.horizontalSpacing),
        child: Column(
          children: [
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trText('DIAGNOSTIC ARCHIVE'),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 3.0, color: AppTheme.secondary),
                    ),
                    SizedBox(height: 8),
                    Text(
                      trText('Detection'),
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    Text(
                      trText('History'),
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Icon(LucideIcons.search, color: AppTheme.primary),
                ),
              ],
            ),
            SizedBox(height: 48),
            _TotalScansCard(),
            SizedBox(height: 48),
            _StatusOverview(),
            SizedBox(height: 48),
            _HistoryTimeline(),
            SizedBox(height: 15),
            Text(
              trText('RECENT ACTIVITY LOG'),
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 3.0, color: AppTheme.secondary),
            ),
            SizedBox(height: 15),
            _ScansTimeline(),

            SizedBox(height: 120),
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
              loading: () => Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Text(trText(error.toString())),
              data: (jobs) =>
                  Container(
                    padding: EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(trText('TOTAL SCANS'), style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
                            SizedBox(height: 24),
                            Text(trText(jobs.length.toString()), style: TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: Colors.white)),
                            SizedBox(height: 8),
                            Text(trText('Across all active sectors.'), style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                        Icon(LucideIcons.camera, color: Colors.white24, size: 80),
                      ],
                    ),
                  ));
  }
}

class _StatusOverview extends ConsumerWidget {
  const _StatusOverview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(weedJobsProvider);

    return jobsAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Text(trText(error.toString())),
        data: (jobs) {
          final completed = jobs
              .where((j) => j['status'] == 'COMPLETED')
              .length;

          final pending = jobs
              .where((j) =>
          j['status'] == 'QUEUED' ||
              j['status'] == 'PROCESSING')
              .length;
          return
            Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: IntrinsicHeight( // Ensures the divider matches the height of the content
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center, // Changed to center
                          children: [
                            Text(
                                trText('THREATS NEUTRALIZED'),
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0)
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min, // Keep content tight
                              children: [
                                Text(
                                    trText(completed.toString()),
                                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.primary)
                                ),
                                SizedBox(width: 8),
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
                          crossAxisAlignment: CrossAxisAlignment.center, // Changed to center
                          children: [
                            Text(
                                trText('PENDING ANALYSIS'),
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0)
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min, // Keep content tight
                              children: [
                                Text(
                                    trText(pending.toString()),
                                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.onSurface)
                                ),
                                SizedBox(width: 8),
                                Icon(LucideIcons.clock, color: Colors.orange.shade400, size: 20),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );});
  }
}

class _HistoryTimeline extends StatelessWidget {
  const _HistoryTimeline();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TimelineItem(
          species: 'Spotted Knapweed',
          location: 'Sector 4B',
          date: '14 May, 2024',
          status: 'NEUTRALIZED',
          statusColor: Colors.green,
        ),
        _TimelineItem(
          species: 'Field Bindweed',
          location: 'Sector 2C',
          date: '12 May, 2024',
          status: 'PENDING ACTION',
          statusColor: Colors.orange,
        ),
        _TimelineItem(
          species: 'Canada Thistle',
          location: 'Sector 7A',
          date: '08 May, 2024',
          status: 'NEUTRALIZED',
          statusColor: Colors.green,
        ),
        _TimelineItem(
          species: 'Common Ragweed',
          location: 'North Orchard',
          date: '02 May, 2024',
          status: 'NEUTRALIZED',
          statusColor: Colors.green,
        ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String species;
  final String location;
  final String date;
  final String status;
  final Color statusColor;

  const _TimelineItem({
    required this.species,
    required this.location,
    required this.date,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(24)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trText(species), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(trText('$location • $date'), style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(100)),
            child: Text(
              trText(status),
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: statusColor, letterSpacing: 1.0),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScansTimeline extends ConsumerWidget  {
  const _ScansTimeline();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(weedJobsProvider);
    return jobsAsync.when(
      loading: () => Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Text(trText(error.toString())),
      data: (jobs) => Column(
        children: jobs.asMap().entries.map((entry) {
          final index = entry.key;
          final job = entry.value;

          final status = job['status'] as String;

          return SharedTimelineItem(
            isFirst: index == 0,
            label: status,
            title: 'Weed Detection',
            subtitle: job['createdAt'] ?? '',
            metricLabel: 'JOB',
            metricValue: job['jobId'].toString().substring(0, 6),
            dotColor: status == 'COMPLETED'
                ? Colors.green
                : status == 'FAILED'
                ? Colors.red
                : AppTheme.primary,
            isProcessing:
            status == 'PROCESSING' ||
                status == 'QUEUED',
            useCard: true,
            onTap: () => context.go('/weed/map'),
          );
        }).toList(),
      ),
    );
  }
}

