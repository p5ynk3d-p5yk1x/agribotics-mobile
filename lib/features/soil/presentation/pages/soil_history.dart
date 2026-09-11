import 'package:agribotics/core/providers/app_providers.dart';
import 'package:agribotics/shared/widgets/shared_timeline_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';

class SoilNutrientHistory extends ConsumerStatefulWidget {
  const SoilNutrientHistory({super.key});

  @override
  ConsumerState<SoilNutrientHistory> createState() => _SoilNutrientHistoryState();
}

class _SoilNutrientHistoryState extends ConsumerState<SoilNutrientHistory> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.invalidate(soilJobsProvider));
  }

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(soilJobsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.horizontalSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            'CHRONOLOGICAL RECORDS',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Soil Analysis',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          Text(
            'History',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 24),
          Text(
            "A definitive ledger of your land's nutritional evolution and strata health metrics across the seasons.",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 48),
          jobsAsync.when(
            loading: () => const _LoadingState(),
            error: (error,stackTrace) => _ErrorState(
              message: _errorMessage(error),
              onRetry: () => ref.invalidate(soilJobsProvider),
            ),
            data: (jobs) => _HistoryContent(jobs: jobs),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  String _errorMessage(Object error) {
    final value = error.toString();
    if (value.startsWith('Exception: ')) return value.substring(11);
    return value;
  }
}

class _HistoryContent extends StatelessWidget {
  final List<Map<String,dynamic>> jobs;

  const _HistoryContent({required this.jobs});

  @override
  Widget build(BuildContext context) {
    final completed = jobs.where((job) => job['status']?.toString().toUpperCase() == 'COMPLETED').length;
    final active = jobs.where((job) {
      final status = job['status']?.toString().toUpperCase();
      return status == 'QUEUED' || status == 'PROCESSING';
    }).length;

    return Column(
      children: [
        _StatsGrid(
          totalJobs: jobs.length,
          completedJobs: completed,
          activeJobs: active,
        ).animate().fadeIn(delay: 200.ms).moveY(begin: 10,end: 0),
        const SizedBox(height: 30),
        const Center(
          child: Text(
            'RECENT ACTIVITY LOG',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
              color: AppTheme.secondary,
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (jobs.isEmpty)
          const _EmptyState()
        else
          _HistoryTimeline(jobs: jobs),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final int totalJobs;
  final int completedJobs;
  final int activeJobs;

  const _StatsGrid({
    required this.totalJobs,
    required this.completedJobs,
    required this.activeJobs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.onSurfaceVariant.withValues(alpha: .05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              LucideIcons.activity,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL ANALYSES',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  '$totalJobs',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '$completedJobs completed • $activeJobs active',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTimeline extends StatelessWidget {
  final List<Map<String,dynamic>> jobs;

  const _HistoryTimeline({required this.jobs});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(jobs.length,(index) {
        final job = jobs[index];
        final jobId = job['jobId']?.toString() ?? '';
        final status = job['status']?.toString().toUpperCase() ?? 'UNKNOWN';
        final createdAt = _formatDate(job['createdAt']);
        final isProcessing = status == 'QUEUED' || status == 'PROCESSING';

        return SharedTimelineItem(
          label: status,
          title: 'Soil Nutrient Analysis',
          subtitle: '$createdAt • ${_shortJobId(jobId)}',
          metricLabel: 'STATUS',
          metricValue: _statusMetric(status),
          dotColor: _statusColor(status),
          isFirst: index == 0,
          isProcessing: isProcessing,
          useCard: isProcessing,
          onTap: jobId.isEmpty ? null : () => context.go('/soil/nutrient-map/$jobId'),
        ).animate().fadeIn(
          delay: Duration(milliseconds: 100 + (index * 70)),
          duration: 400.ms,
        ).moveY(begin: 10,end: 0);
      }),
    );
  }

  static String _formatDate(dynamic value) {
    if (value == null) return 'Unknown date';

    final date = DateTime.tryParse(value.toString())?.toLocal();
    if (date == null) return 'Unknown date';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static String _shortJobId(String jobId) {
    if (jobId.isEmpty) return 'Unknown job';
    if (jobId.length <= 8) return jobId;
    return 'Job ${jobId.substring(0,8)}';
  }

  static String _statusMetric(String status) {
    switch (status) {
      case 'COMPLETED':
        return 'READY';
      case 'PROCESSING':
        return 'RUNNING';
      case 'QUEUED':
        return 'QUEUED';
      case 'FAILED':
        return 'FAILED';
      default:
        return '--';
    }
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'QUEUED':
      case 'PROCESSING':
        return AppTheme.primary;
      case 'FAILED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 42),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              LucideIcons.flaskConical,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No soil analyses yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Completed and active soil analysis jobs will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 240,
      child: Center(
        child: CircularProgressIndicator(
          color: AppTheme.primary,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(
            LucideIcons.alertCircle,
            color: Colors.red,
            size: 30,
          ),
          const SizedBox(height: 14),
          const Text(
            'Unable to load soil history',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              height: 1.5,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 18),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(LucideIcons.refreshCw),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}