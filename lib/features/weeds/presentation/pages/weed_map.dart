import 'package:agribotics/core/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';

class WeedMap extends ConsumerWidget {
  final String jobId;

  const WeedMap({super.key,required this.jobId});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final jobAsync = ref.watch(weedJobProvider(jobId));
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: jobAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
        error: (error,stackTrace) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(weedJobProvider(jobId)),
        ),
        data: (job) => _WeedResultContent(job: job),
      ),
    );
  }
}

class _WeedResultContent extends StatelessWidget {
  final Map<String,dynamic> job;

  const _WeedResultContent({required this.job});

  @override
  Widget build(BuildContext context) {
    final status = job['status']?.toString() ?? 'UNKNOWN';
    final result = job['result'] is Map ? Map<String,dynamic>.from(job['result'] as Map) : <String,dynamic>{};
    final rawPrediction = result['prediction']?.toString() ?? 'Unknown Species';
    final confidence = _parseConfidence(result['confidence']);
    final prediction = _formatPrediction(rawPrediction);
    final commonName = _extractCommonName(prediction);
    final scientificName = _extractScientificName(prediction);
    final createdAt = _formatDate(job['createdAt']?.toString());
    final rawImageUrl = job['imageUrl']?.toString().trim();
    final imageUrl = rawImageUrl != null && rawImageUrl.isNotEmpty ? rawImageUrl : null;

    if (status != 'COMPLETED' || result.isEmpty) {
      return _IncompleteJobState(status: status);
    }

    return SingleChildScrollView(
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
                    'SOIL & FLORA',
                    style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold,letterSpacing: 3.0,color: AppTheme.secondary),
                  ),
                  const SizedBox(height: 8),
                  Text('Intelligence',style: Theme.of(context).textTheme.displayLarge),
                ],
              ),
            ],
          ),
          const SizedBox(height: 48),
          if (imageUrl != null) ...[
            _DetectionImageCard(imageUrl: imageUrl),
            const SizedBox(height: 32),
          ],
          _DetectionSummaryCard(
            commonName: commonName,
            scientificName: scientificName,
            confidence: confidence,
          ),
          const SizedBox(height: 32),
          _ConfidenceSection(confidence: confidence),
          const SizedBox(height: 48),
          _AnalysisCard(
            prediction: prediction,
            confidence: confidence,
            createdAt: createdAt,
          ),
          const SizedBox(height: 48),
          _SpeciesIdentificationSection(
            commonName: commonName,
            scientificName: scientificName,
            confidence: confidence,
          ),
          const SizedBox(height: 48),
          _JobInformationCard(
            jobId: job['jobId']?.toString() ?? '',
            status: status,
            createdAt: createdAt,
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  static double _parseConfidence(dynamic value) {
    if (value is num) return value.toDouble().clamp(0.0,1.0);
    return double.tryParse(value?.toString() ?? '')?.clamp(0.0,1.0) ?? 0.0;
  }

  static String _formatPrediction(String prediction) {
    var value = prediction.replaceAll('_',' ').trim();
    value = value.replaceFirst(RegExp(r'^\d+\.'),'');
    return value.trim();
  }

  static String _extractCommonName(String prediction) {
    final index = prediction.indexOf('(');
    if (index == -1) return prediction.trim();
    return prediction.substring(0,index).trim();
  }

  static String _extractScientificName(String prediction) {
    final start = prediction.indexOf('(');
    final end = prediction.lastIndexOf(')');
    if (start == -1 || end == -1 || end <= start) return '';
    return prediction.substring(start + 1,end).trim();
  }

  static String _formatDate(String? value) {
    if (value == null || value.isEmpty) return 'Unknown';
    final parsed = DateTime.tryParse(value)?.toLocal();
    if (parsed == null) return value;
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final day = parsed.day.toString().padLeft(2,'0');
    final month = months[parsed.month - 1];
    final year = parsed.year;
    final hour = parsed.hour.toString().padLeft(2,'0');
    final minute = parsed.minute.toString().padLeft(2,'0');
    return '$day $month, $year • $hour:$minute';
  }
}

class _DetectionImageCard extends StatelessWidget {
  final String imageUrl;

  const _DetectionImageCard({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CAPTURED SAMPLE',
              style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold,letterSpacing: 2.0,color: AppTheme.secondary),
            ),
            Row(
              children: [
                Icon(LucideIcons.camera,size: 14,color: AppTheme.primary),
                SizedBox(width: 6),
                Text(
                  'SOURCE IMAGE',
                  style: TextStyle(fontSize: 9,fontWeight: FontWeight.bold,letterSpacing: 1.0,color: AppTheme.primary),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: AppTheme.surface),
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  loadingBuilder: (context,child,loadingProgress) {
                    if (loadingProgress == null) return child;
                    final expectedBytes = loadingProgress.expectedTotalBytes;
                    return Container(
                      color: AppTheme.surface,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        color: AppTheme.primary,
                        value: expectedBytes != null && expectedBytes > 0
                            ? loadingProgress.cumulativeBytesLoaded / expectedBytes
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context,error,stackTrace) {
                    return Container(
                      color: AppTheme.surface,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(32),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.imageOff,size: 40,color: AppTheme.onSurfaceVariant),
                          SizedBox(height: 16),
                          Text(
                            'IMAGE UNAVAILABLE',
                            style: TextStyle(fontSize: 11,fontWeight: FontWeight.bold,letterSpacing: 1.5),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'The captured sample could not be loaded.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12,color: AppTheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.scanLine,size: 13,color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'ANALYZED SAMPLE',
                          style: TextStyle(fontSize: 8,fontWeight: FontWeight.bold,letterSpacing: 1.0,color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DetectionSummaryCard extends StatelessWidget {
  final String commonName;
  final String scientificName;
  final double confidence;

  const _DetectionSummaryCard({
    required this.commonName,
    required this.scientificName,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (confidence * 100).toStringAsFixed(1);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: AppTheme.primary,borderRadius: BorderRadius.circular(32)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SPECIES DETECTED',
                style: TextStyle(color: Colors.white54,fontSize: 11,fontWeight: FontWeight.bold,letterSpacing: 2.0),
              ),
              Icon(LucideIcons.leaf,color: Colors.white,size: 22),
            ],
          ),
          const SizedBox(height: 40),
          Text(
            commonName,
            style: const TextStyle(fontSize: 32,fontWeight: FontWeight.w900,color: Colors.white,height: 1.1),
          ),
          if (scientificName.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              scientificName,
              style: const TextStyle(fontSize: 14,fontStyle: FontStyle.italic,color: Colors.white70),
            ),
          ],
          const SizedBox(height: 32),
          Row(
            children: [
              const Icon(LucideIcons.activity,color: Colors.white70,size: 18),
              const SizedBox(width: 10),
              Text(
                '$percentage% MODEL CONFIDENCE',
                style: const TextStyle(fontSize: 10,fontWeight: FontWeight.bold,color: Colors.white70,letterSpacing: 1.3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConfidenceSection extends StatelessWidget {
  final double confidence;

  const _ConfidenceSection({required this.confidence});

  @override
  Widget build(BuildContext context) {
    final percentage = confidence * 100;
    final label = percentage >= 80
        ? 'HIGH CONFIDENCE'
        : percentage >= 60
        ? 'MODERATE CONFIDENCE'
        : 'LOW CONFIDENCE';
    final color = percentage >= 80
        ? Colors.green
        : percentage >= 60
        ? Colors.orange
        : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'CLASSIFICATION CONFIDENCE',
              style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold,letterSpacing: 1.5),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w900,color: AppTheme.primary),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: confidence,
            minHeight: 10,
            backgroundColor: AppTheme.outline.withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14,vertical: 8),
          decoration: BoxDecoration(color: color.withOpacity(0.1),borderRadius: BorderRadius.circular(100)),
          child: Text(
            label,
            style: TextStyle(fontSize: 9,fontWeight: FontWeight.bold,color: color,letterSpacing: 1.0),
          ),
        ),
      ],
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  final String prediction;
  final double confidence;
  final String createdAt;

  const _AnalysisCard({
    required this.prediction,
    required this.confidence,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: AppTheme.surface,borderRadius: BorderRadius.circular(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ANALYSIS SUMMARY',
            style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold,letterSpacing: 2.0,color: AppTheme.secondary),
          ),
          const SizedBox(height: 24),
          _InfoRow(
            icon: LucideIcons.leaf,
            label: 'PREDICTION',
            value: prediction,
          ),
          const SizedBox(height: 20),
          _InfoRow(
            icon: LucideIcons.gauge,
            label: 'CONFIDENCE',
            value: '${(confidence * 100).toStringAsFixed(1)}%',
          ),
          const SizedBox(height: 20),
          _InfoRow(
            icon: LucideIcons.calendar,
            label: 'DETECTED',
            value: createdAt,
          ),
        ],
      ),
    );
  }
}

class _SpeciesIdentificationSection extends StatelessWidget {
  final String commonName;
  final String scientificName;
  final double confidence;

  const _SpeciesIdentificationSection({
    required this.commonName,
    required this.scientificName,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    final risk = confidence >= 0.8
        ? 'HIGH'
        : confidence >= 0.6
        ? 'MEDIUM'
        : 'UNCONFIRMED';

    final riskColor = confidence >= 0.8
        ? Colors.red
        : confidence >= 0.6
        ? Colors.orange
        : Colors.grey;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SPECIES IDENTIFICATION',
          style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold,letterSpacing: 3.0,color: AppTheme.secondary),
        ),
        const SizedBox(height: 24),
        InkWell(
          onTap: () => context.go('/weed/detail'),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppTheme.surface,borderRadius: BorderRadius.circular(24)),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: AppTheme.background,borderRadius: BorderRadius.circular(14)),
                  child: const Icon(LucideIcons.leaf,color: AppTheme.primary,size: 22),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        commonName,
                        style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16),
                      ),
                      if (scientificName.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          scientificName,
                          style: const TextStyle(fontSize: 12,fontStyle: FontStyle.italic,color: AppTheme.onSurfaceVariant),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'DETECTION',
                      style: TextStyle(fontSize: 8,fontWeight: FontWeight.bold,letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      risk,
                      style: TextStyle(fontSize: 13,fontWeight: FontWeight.w900,color: riskColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _JobInformationCard extends StatelessWidget {
  final String jobId;
  final String status;
  final String createdAt;

  const _JobInformationCard({
    required this.jobId,
    required this.status,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.outline.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DIAGNOSTIC RECORD',
            style: TextStyle(fontSize: 10,fontWeight: FontWeight.bold,letterSpacing: 2.0,color: AppTheme.secondary),
          ),
          const SizedBox(height: 24),
          _InfoRow(icon: LucideIcons.hash,label: 'JOB ID',value: jobId),
          const SizedBox(height: 20),
          _InfoRow(icon: LucideIcons.checkCircle,label: 'STATUS',value: status),
          const SizedBox(height: 20),
          _InfoRow(icon: LucideIcons.clock,label: 'CREATED',value: createdAt),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: AppTheme.background,borderRadius: BorderRadius.circular(12)),
          child: Icon(icon,size: 18,color: AppTheme.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 9,fontWeight: FontWeight.bold,letterSpacing: 1.3,color: AppTheme.secondary),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(fontSize: 13,fontWeight: FontWeight.w600,color: AppTheme.onSurface),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IncompleteJobState extends StatelessWidget {
  final String status;

  const _IncompleteJobState({required this.status});

  @override
  Widget build(BuildContext context) {
    final processing = status == 'QUEUED' || status == 'PROCESSING';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.horizontalSpacing),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              processing ? LucideIcons.loader : LucideIcons.alertTriangle,
              size: 48,
              color: processing ? AppTheme.primary : Colors.orange,
            ),
            const SizedBox(height: 24),
            Text(
              processing ? 'ANALYSIS IN PROGRESS' : 'RESULT UNAVAILABLE',
              style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w900,letterSpacing: 1.5),
            ),
            const SizedBox(height: 12),
            Text(
              processing
                  ? 'This weed detection has not completed yet.'
                  : 'No inference result was returned for this detection.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13,color: AppTheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/weed/history'),
              child: const Text('Back to History'),
            ),
          ],
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.horizontalSpacing),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.alertCircle,size: 48,color: Colors.red),
            const SizedBox(height: 24),
            const Text(
              'UNABLE TO LOAD RESULT',
              style: TextStyle(fontSize: 14,fontWeight: FontWeight.w900,letterSpacing: 1.5),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12,color: AppTheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}