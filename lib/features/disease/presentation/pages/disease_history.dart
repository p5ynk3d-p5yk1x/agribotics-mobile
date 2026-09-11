import 'package:agribotics/core/providers/app_providers.dart';
import 'package:agribotics/core/theme/app_theme.dart';
import 'package:agribotics/shared/widgets/shared_timeline_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DiseaseDetectionHistory extends ConsumerWidget {
  const DiseaseDetectionHistory({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(diseaseJobsProvider);
    return RefreshIndicator(
      onRefresh: () => ref.refresh(diseaseJobsProvider.future),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.horizontalSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Text(
              'PATHOGEN SURVEILLANCE',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.redAccent),
            ),
            const SizedBox(height: 8),
            Text('Diagnostic', style: Theme.of(context).textTheme.displayLarge),
            Text('Registry', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 24),
            Text(
              'An archival record of submitted disease diagnoses and their current processing status.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 36),
            _SummaryCard(jobsAsync: jobsAsync).animate().fadeIn(duration: 350.ms).moveY(begin: 10, end: 0),
            const SizedBox(height: 30),
            const Center(
              child: Text(
                'DETECTION LOG & TIMELINE',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 3, color: AppTheme.secondary),
              ),
            ),
            const SizedBox(height: 10),
            jobsAsync.when(
              loading: () => const _HistoryLoading(),
              error: (error, stackTrace) => _HistoryError(
                message: _errorMessage(error),
                onRetry: () => ref.invalidate(diseaseJobsProvider),
              ),
              data: (jobs) => jobs.isEmpty ? const _EmptyHistory() : _DetectionTimeline(jobs: jobs),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  static String _errorMessage(Object error) {
    final message = error.toString();
    if (message.contains('401')) return 'Your session has expired. Please log in again.';
    if (message.contains('403')) return 'You do not have permission to view these diagnoses.';
    if (message.contains('SocketException') || message.contains('connection')) return 'The server could not be reached.';
    return 'Disease history could not be loaded.';
  }
}

class _SummaryCard extends StatelessWidget {
  final AsyncValue<List<Map<String, dynamic>>> jobsAsync;

  const _SummaryCard({required this.jobsAsync});

  @override
  Widget build(BuildContext context) {
    final jobs = jobsAsync.asData?.value ?? <Map<String, dynamic>>[];
    final completed = jobs.where((job) => _status(job) == 'COMPLETED').length;
    final active = jobs.where((job) {
      final status = _status(job);
      return status == 'QUEUED' || status == 'PROCESSING';
    }).length;
    final failed = jobs.where((job) => _status(job) == 'FAILED').length;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.onSurfaceVariant.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryMetric(
              icon: LucideIcons.microscope,
              label: 'COMPLETED',
              value: completed.toString().padLeft(2, '0'),
              color: AppTheme.primary,
            ),
          ),
          Container(width: 1, height: 56, color: AppTheme.secondary.withOpacity(0.15)),
          Expanded(
            child: _SummaryMetric(
              icon: LucideIcons.loader,
              label: 'ACTIVE',
              value: active.toString().padLeft(2, '0'),
              color: Colors.orange,
            ),
          ),
          Container(width: 1, height: 56, color: AppTheme.secondary.withOpacity(0.15)),
          Expanded(
            child: _SummaryMetric(
              icon: LucideIcons.alertTriangle,
              label: 'FAILED',
              value: failed.toString().padLeft(2, '0'),
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  static String _status(Map<String, dynamic> job) => job['status']?.toString().toUpperCase() ?? 'UNKNOWN';
}

class _SummaryMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryMetric({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 10),
        Text(value, style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1, color: AppTheme.secondary),
        ),
      ],
    );
  }
}

class _DetectionTimeline extends StatelessWidget {
  final List<Map<String, dynamic>> jobs;

  const _DetectionTimeline({required this.jobs});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(jobs.length, (index) {
        final job = jobs[index];
        final jobId = job['jobId']?.toString() ?? '';
        final status = job['status']?.toString().toUpperCase() ?? 'UNKNOWN';
        final failureReason = job['failureReason']?.toString();
        final isProcessing = status == 'QUEUED' || status == 'PROCESSING';
        return SharedTimelineItem(
          label: _statusLabel(status),
          title: _title(status),
          subtitle: failureReason?.isNotEmpty == true ? failureReason! : _formatDate(job['createdAt']),
          metricLabel: 'STATUS',
          metricValue: _metricValue(status),
          dotColor: _statusColor(status),
          isFirst: index == 0,
          isProcessing: isProcessing,
          useCard: true,
          onTap: jobId.isEmpty ? null : () => context.push('/disease/map/$jobId'),
        ).animate().fadeIn(delay: Duration(milliseconds: 80 * index)).moveY(begin: 8, end: 0);
      }),
    );
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'QUEUED':
        return 'QUEUED';
      case 'PROCESSING':
        return 'ANALYZING';
      case 'COMPLETED':
        return 'COMPLETED';
      case 'FAILED':
        return 'FAILED';
      default:
        return status;
    }
  }

  static String _title(String status) {
    switch (status) {
      case 'QUEUED':
        return 'Disease diagnosis queued';
      case 'PROCESSING':
        return 'Analyzing plant sample';
      case 'COMPLETED':
        return 'Disease diagnosis completed';
      case 'FAILED':
        return 'Disease diagnosis failed';
      default:
        return 'Disease diagnosis';
    }
  }

  static String _metricValue(String status) {
    switch (status) {
      case 'QUEUED':
        return 'WAIT';
      case 'PROCESSING':
        return 'LIVE';
      case 'COMPLETED':
        return 'DONE';
      case 'FAILED':
        return 'ERROR';
      default:
        return '--';
    }
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'QUEUED':
      case 'PROCESSING':
        return Colors.orange;
      case 'COMPLETED':
        return AppTheme.primary;
      case 'FAILED':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  static String _formatDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
    if (date == null) return 'Submission date unavailable';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '${months[date.month - 1]} ${date.day}, ${date.year} • $hour:$minute $period';
  }
}

class _HistoryLoading extends StatelessWidget {
  const _HistoryLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 70),
      child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
    );
  }
}

class _HistoryError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _HistoryError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            const Icon(LucideIcons.alertTriangle, size: 42, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(LucideIcons.microscope, size: 48, color: AppTheme.secondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text('No disease diagnoses yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Completed and ongoing diagnoses will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.secondary),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.go('/disease/detection'),
              child: const Text('Start diagnosis'),
            ),
          ],
        ),
      ),
    );
  }
}