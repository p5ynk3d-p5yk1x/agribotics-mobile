import 'package:agribotics/core/providers/app_providers.dart';
import 'package:agribotics/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DiseasePathogenMapScreen extends ConsumerWidget {
  final String jobId;

  const DiseasePathogenMapScreen({super.key,required this.jobId});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final jobAsync = ref.watch(diseaseJobProvider(jobId));
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          onRefresh: () => ref.refresh(diseaseJobProvider(jobId).future),
          child: jobAsync.when(
            loading: () => const _LoadingView(),
            error: (error,stackTrace) => _ErrorView(
              message: _getErrorMessage(error),
              onRetry: () => ref.invalidate(diseaseJobProvider(jobId)),
            ),
            data: (job) => _DiseaseJobView(job: job),
          ),
        ),
      ),
    );
  }

  String _getErrorMessage(Object error) {
    final message = error.toString();
    if (message.contains('401')) return 'Your session has expired. Please log in again.';
    if (message.contains('403')) return 'You do not have permission to view this diagnosis.';
    if (message.contains('404')) return 'This disease diagnosis could not be found.';
    if (message.toLowerCase().contains('connection')) return 'The server could not be reached.';
    return 'The disease diagnosis could not be loaded.';
  }
}

class _DiseaseJobView extends StatelessWidget {
  final Map<String,dynamic> job;

  const _DiseaseJobView({required this.job});

  @override
  Widget build(BuildContext context) {
    final status = job['status']?.toString().toUpperCase() ?? 'UNKNOWN';
    final result = _mapValue(job['result']);

    if (status == 'FAILED') {
      return _FailedJobView(
        status: status,
        createdAt: job['createdAt'],
        failureReason: job['failureReason']?.toString(),
      );
    }

    if (status != 'COMPLETED') {
      return _ProcessingJobView(
        status: status,
        createdAt: job['createdAt'],
      );
    }

    if (result == null) {
      return _MissingResultView(
        status: status,
        createdAt: job['createdAt'],
      );
    }

    final plantName = _formatName(result['plantName']?.toString() ?? 'Unknown plant');
    final diseaseName = _formatName(result['diseaseName']?.toString() ?? 'Unknown disease');
    final plantConfidence = _confidence(result['plantConfidence']);
    final diseaseConfidence = _confidence(result['diseaseConfidence']);
    final predictionSkipped = result['diseasePredictionSkipped'] == true;
    final skipReason = result['skipReason']?.toString();
    final predictions = _predictionList(result['topPredictions']);

    final rawOriginalImageUrl = job['imageUrl']?.toString().trim();
    final originalImageUrl = rawOriginalImageUrl != null && rawOriginalImageUrl.isNotEmpty ? rawOriginalImageUrl : null;

    final rawAnnotatedImageUrl = result['annotatedImageUrl']?.toString().trim();
    final annotatedImageUrl = rawAnnotatedImageUrl != null && rawAnnotatedImageUrl.isNotEmpty ? rawAnnotatedImageUrl : null;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(
                  'HEALTH ANALYSIS',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppTheme.secondary.withOpacity(0.8)),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.displayMedium,
                    children: const [
                      TextSpan(text: 'Disease Pathogen '),
                      TextSpan(
                        text: 'Map',
                        style: TextStyle(color: AppTheme.primary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _TopMetrics(
                  plantName: plantName,
                  plantConfidence: plantConfidence,
                  diseaseConfidence: diseaseConfidence,
                ),
                const SizedBox(height: 24),
                _JobMetadataCard(
                  status: status,
                  createdAt: job['createdAt'],
                  jobId: job['jobId']?.toString() ?? '',
                ),
                const SizedBox(height: 32),
                if (predictionSkipped)
                  _PredictionSkippedCard(
                    reason: skipReason ?? 'Disease prediction was skipped by the analysis service.',
                  )
                else
                  _PrimaryPredictionCard(
                    diseaseName: diseaseName,
                    confidence: diseaseConfidence,
                  ),
                const SizedBox(height: 32),
                _SectionHeader(
                  title: 'Diagnostic Imaging',
                  subtitle: 'Original sample and annotated analysis',
                  icon: LucideIcons.image,
                ),
                const SizedBox(height: 16),
                _ImageComparison(
                  originalImageUrl: originalImageUrl,
                  annotatedImageUrl: annotatedImageUrl,
                ),
                const SizedBox(height: 40),
                _SectionHeader(
                  title: 'Top Predictions',
                  subtitle: 'The three highest-ranking disease classifications',
                  icon: LucideIcons.barChart3,
                ),
                const SizedBox(height: 16),
                _TopPredictions(predictions: predictions.take(3).toList()),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Map<String,dynamic>? _mapValue(dynamic value) {
    if (value is Map<String,dynamic>) return value;
    if (value is Map) return Map<String,dynamic>.from(value);
    return null;
  }

  static List<Map<String,dynamic>> _predictionList(dynamic value) {
    if (value is! List) return [];
    return value.whereType<Map>().map((prediction) => Map<String,dynamic>.from(prediction)).toList();
  }

  static double _confidence(dynamic value) {
    if (value is num) return value.toDouble().clamp(0.0,1.0);
    return double.tryParse(value?.toString() ?? '')?.clamp(0.0,1.0) ?? 0.0;
  }
}

class _TopMetrics extends StatelessWidget {
  final String plantName;
  final double plantConfidence;
  final double diseaseConfidence;

  const _TopMetrics({
    required this.plantName,
    required this.plantConfidence,
    required this.diseaseConfidence,
  });

  @override
  Widget build(BuildContext context) {
    final diseaseScore = (diseaseConfidence * 100).round();
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IDENTIFIED PLANT',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  plantName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(fontSize: 20,fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_percentage(plantConfidence)} confidence',
                  style: GoogleFonts.inter(fontSize: 11,color: AppTheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CONFIDENCE SCORE',
                  style: GoogleFonts.inter(fontSize: 10,fontWeight: FontWeight.w700,color: Colors.white60),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: diseaseScore.toString(),
                          style: GoogleFonts.manrope(fontSize: 32,fontWeight: FontWeight.w800,color: Colors.white),
                        ),
                        TextSpan(
                          text: '/100',
                          style: GoogleFonts.manrope(fontSize: 14,color: Colors.white70),
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

class _JobMetadataCard extends StatelessWidget {
  final String status;
  final dynamic createdAt;
  final String jobId;

  const _JobMetadataCard({
    required this.status,
    required this.createdAt,
    required this.jobId,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(status);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: statusColor,shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Text(
                _formatName(status),
                style: GoogleFonts.inter(fontSize: 12,fontWeight: FontWeight.w800,color: statusColor,letterSpacing: 0.8),
              ),
              const Spacer(),
              Text(
                _formatDate(createdAt),
                style: GoogleFonts.inter(fontSize: 11,color: AppTheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1,color: AppTheme.onSurfaceVariant.withOpacity(0.12)),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'JOB ID',
                style: GoogleFonts.inter(fontSize: 9,fontWeight: FontWeight.w800,letterSpacing: 1,color: AppTheme.secondary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SelectableText(
                  jobId,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.inter(fontSize: 11,fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrimaryPredictionCard extends StatelessWidget {
  final String diseaseName;
  final double confidence;

  const _PrimaryPredictionCard({
    required this.diseaseName,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    final color = _predictionColor(diseaseName);
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: color.withOpacity(0.12),shape: BoxShape.circle),
                child: Icon(_predictionIcon(diseaseName),color: color,size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'TOP PREDICTED DISEASE',
                  style: GoogleFonts.inter(fontSize: 10,fontWeight: FontWeight.w800,letterSpacing: 1.2,color: AppTheme.secondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            diseaseName,
            style: GoogleFonts.manrope(fontSize: 28,fontWeight: FontWeight.w800,height: 1.15,color: color),
          ),
          const SizedBox(height: 10),
          Text(
            _isHealthy(diseaseName)
                ? 'The analyzed plant sample was classified as healthy.'
                : 'The analyzed plant sample most closely matches this disease classification.',
            style: GoogleFonts.inter(fontSize: 14,height: 1.5,color: AppTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 26),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PREDICTION CONFIDENCE',
                style: GoogleFonts.inter(fontSize: 10,fontWeight: FontWeight.w800,letterSpacing: 0.8,color: AppTheme.secondary),
              ),
              Text(
                _percentage(confidence),
                style: GoogleFonts.manrope(fontSize: 18,fontWeight: FontWeight.w800,color: color),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: confidence,
              minHeight: 12,
              color: color,
              backgroundColor: color.withOpacity(0.12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageComparison extends StatelessWidget {
  final String? originalImageUrl;
  final String? annotatedImageUrl;

  const _ImageComparison({
    required this.originalImageUrl,
    required this.annotatedImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context,constraints) {
        if (constraints.maxWidth < 650) {
          return Column(
            children: [
              _DiagnosticImageCard(
                label: 'BEFORE',
                title: 'Original Sample',
                imageUrl: originalImageUrl,
              )
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _DiagnosticImageCard(
                label: 'BEFORE',
                title: 'Original Sample',
                imageUrl: originalImageUrl,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _DiagnosticImageCard(
                label: 'AFTER',
                title: 'Analyzed Sample',
                imageUrl: annotatedImageUrl,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DiagnosticImageCard extends StatelessWidget {
  final String label;
  final String title;
  final String? imageUrl;

  const _DiagnosticImageCard({
    required this.label,
    required this.title,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: AspectRatio(
              aspectRatio: 1,
              child: imageUrl == null
                  ? const _ImageUnavailable()
                  : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                loadingBuilder: (context,child,loadingProgress) {
                  if (loadingProgress == null) return child;
                  final total = loadingProgress.expectedTotalBytes;
                  final progress = total != null && total > 0
                      ? loadingProgress.cumulativeBytesLoaded / total
                      : null;
                  return Container(
                    color: AppTheme.surfaceContainerLow,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      value: progress,
                      color: AppTheme.primary,
                    ),
                  );
                },
                errorBuilder: (context,error,stackTrace) => const _ImageUnavailable(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                  decoration: BoxDecoration(
                    color: label == 'AFTER'
                        ? AppTheme.primary.withOpacity(0.12)
                        : AppTheme.onSurfaceVariant.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: label == 'AFTER' ? AppTheme.primary : AppTheme.secondary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.manrope(fontSize: 14,fontWeight: FontWeight.w700),
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

class _ImageUnavailable extends StatelessWidget {
  const _ImageUnavailable();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surfaceContainerLow,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.imageOff,size: 36,color: AppTheme.secondary.withOpacity(0.55)),
            const SizedBox(height: 10),
            Text(
              'Image unavailable',
              style: GoogleFonts.inter(fontSize: 12,color: AppTheme.secondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopPredictions extends StatelessWidget {
  final List<Map<String,dynamic>> predictions;

  const _TopPredictions({required this.predictions});

  @override
  Widget build(BuildContext context) {
    if (predictions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Text('No prediction rankings were returned.'),
      );
    }

    return Column(
      children: List.generate(predictions.length,(index) {
        final prediction = predictions[index];
        final rank = prediction['rank'] is num ? (prediction['rank'] as num).toInt() : index + 1;
        final diseaseName = _formatName(prediction['diseaseName']?.toString() ?? 'Unknown disease');
        final confidence = _parseConfidence(prediction['confidence']);

        return _PredictionCard(
          rank: rank,
          diseaseName: diseaseName,
          confidence: confidence,
          isPrimary: index == 0,
        );
      }),
    );
  }
}

class _PredictionCard extends StatelessWidget {
  final int rank;
  final String diseaseName;
  final double confidence;
  final bool isPrimary;

  const _PredictionCard({
    required this.rank,
    required this.diseaseName,
    required this.confidence,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPrimary ? AppTheme.primary : AppTheme.secondary;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        border: isPrimary ? Border.all(color: AppTheme.primary.withOpacity(0.2)) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              rank.toString().padLeft(2,'0'),
              style: GoogleFonts.manrope(fontSize: 15,fontWeight: FontWeight.w800,color: color),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  diseaseName,
                  style: GoogleFonts.manrope(fontSize: 16,fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: confidence,
                    minHeight: 6,
                    color: color,
                    backgroundColor: color.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Text(
            _percentage(confidence),
            style: GoogleFonts.manrope(fontSize: 14,fontWeight: FontWeight.w800,color: color),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon,color: AppTheme.primary,size: 21),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,style: GoogleFonts.manrope(fontSize: 24,fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(subtitle,style: GoogleFonts.inter(fontSize: 12,color: AppTheme.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}

class _PredictionSkippedCard extends StatelessWidget {
  final String reason;

  const _PredictionSkippedCard({required this.reason});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.alertTriangle,color: Colors.orange),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DISEASE PREDICTION SKIPPED',
                  style: GoogleFonts.inter(fontSize: 11,fontWeight: FontWeight.w800,color: Colors.orange),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatName(reason),
                  style: GoogleFonts.inter(fontSize: 14,height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProcessingJobView extends StatelessWidget {
  final String status;
  final dynamic createdAt;

  const _ProcessingJobView({
    required this.status,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 58,
                    height: 58,
                    child: CircularProgressIndicator(strokeWidth: 5,color: AppTheme.primary),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    status == 'QUEUED' ? 'Diagnosis Queued' : 'Analyzing Plant Sample',
                    style: GoogleFonts.manrope(fontSize: 25,fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Submitted ${_formatDate(createdAt)}\nPull down to refresh the current status.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 14,height: 1.6,color: AppTheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FailedJobView extends StatelessWidget {
  final String status;
  final dynamic createdAt;
  final String? failureReason;

  const _FailedJobView({
    required this.status,
    required this.createdAt,
    required this.failureReason,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.alertTriangle,size: 58,color: Colors.redAccent),
                  const SizedBox(height: 24),
                  Text(
                    'Diagnosis Failed',
                    style: GoogleFonts.manrope(fontSize: 25,fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    failureReason?.trim().isNotEmpty == true ? failureReason! : 'The diagnosis could not be completed.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 14,height: 1.6,color: AppTheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _formatDate(createdAt),
                    style: GoogleFonts.inter(fontSize: 12,color: AppTheme.secondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MissingResultView extends StatelessWidget {
  final String status;
  final dynamic createdAt;

  const _MissingResultView({
    required this.status,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.fileWarning,size: 58,color: Colors.orange),
                  const SizedBox(height: 24),
                  Text(
                    'Result Unavailable',
                    style: GoogleFonts.manrope(fontSize: 25,fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'The job completed on ${_formatDate(createdAt)}, but no diagnosis result was returned.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 14,height: 1.6,color: AppTheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.alertTriangle,size: 52,color: Colors.redAccent),
                  const SizedBox(height: 20),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 15,height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(LucideIcons.refreshCw,size: 18),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

double _parseConfidence(dynamic value) {
  if (value is num) return value.toDouble().clamp(0.0,1.0);
  return double.tryParse(value?.toString() ?? '')?.clamp(0.0,1.0) ?? 0.0;
}

String _percentage(double confidence) {
  final percentage = confidence * 100;
  if (percentage == percentage.roundToDouble()) return '${percentage.toInt()}%';
  return '${percentage.toStringAsFixed(1)}%';
}

String _formatName(String value) {
  final normalized = value.replaceAll('_',' ').replaceAll(RegExp(r'\s+'),' ').trim();
  if (normalized.isEmpty) return 'Not available';
  return normalized.split(' ').map((word) {
    if (word.isEmpty) return word;
    if (word.startsWith('(') && word.length > 1) {
      return '(${word[1].toUpperCase()}${word.substring(2).toLowerCase()}';
    }
    return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
  }).join(' ');
}

String _formatDate(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
  if (date == null) return 'Date unavailable';

  const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

  final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
  final minute = date.minute.toString().padLeft(2,'0');
  final period = date.hour >= 12 ? 'PM' : 'AM';

  return '${months[date.month - 1]} ${date.day}, ${date.year} • $hour:$minute $period';
}

Color _statusColor(String status) {
  switch (status) {
    case 'COMPLETED':
      return AppTheme.primary;
    case 'FAILED':
      return Colors.redAccent;
    case 'QUEUED':
    case 'PROCESSING':
      return Colors.orange;
    default:
      return Colors.grey;
  }
}

bool _isHealthy(String diseaseName) {
  return diseaseName.toLowerCase().contains('healthy');
}

Color _predictionColor(String diseaseName) {
  return _isHealthy(diseaseName) ? AppTheme.primary : const Color(0xFF77574D);
}

IconData _predictionIcon(String diseaseName) {
  return _isHealthy(diseaseName) ? LucideIcons.checkCircle : LucideIcons.alertTriangle;
}