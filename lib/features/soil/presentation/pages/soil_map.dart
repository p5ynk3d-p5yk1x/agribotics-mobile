import 'package:agribotics/core/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../core/theme/app_theme.dart';

class SoilNutrientMap extends ConsumerWidget {
  final String jobId;

  const SoilNutrientMap({
    super.key,
    required this.jobId,
  });

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final jobAsync = ref.watch(soilJobProvider(jobId));

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: jobAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: AppTheme.primary,
            ),
          ),
          error: (error,stackTrace) => _ErrorState(
            message: error.toString(),
            onRetry: () => ref.invalidate(soilJobProvider(jobId)),
          ),
          data: (job) => _JobContent(
            jobId: jobId,
            job: job,
          ),
        ),
      ),
    );
  }
}

class _JobContent extends StatelessWidget {
  final String jobId;
  final Map<String,dynamic> job;

  const _JobContent({
    required this.jobId,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    final status = job['status']?.toString().toUpperCase() ?? 'UNKNOWN';
    final result = job['result'] is Map
        ? Map<String,dynamic>.from(job['result'] as Map)
        : <String,dynamic>{};

    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () async {
        final container = ProviderScope.containerOf(context);
        container.invalidate(soilJobProvider(jobId));
        await container.read(soilJobProvider(jobId).future);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.horizontalSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            _buildHeader(status),
            const SizedBox(height: 20),
            _JobStatusCard(
              jobId: jobId,
              status: status,
              createdAt: job['createdAt'],
            ),
            const SizedBox(height: 24),
            const _NutrientToggles(),
            const SizedBox(height: 24),
            const _ConcentrationIndex().animate().fadeIn(delay: 200.ms).moveY(begin: 20,end: 0),
            const SizedBox(height: 32),
            const _NutrientGrid().animate().scale(delay: 400.ms),
            const SizedBox(height: 32),
            _AnalysisResult(
              status: status,
              result: result,
            ).animate().fadeIn(delay: 600.ms).moveY(begin: 20,end: 0),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

class _JobStatusCard extends StatelessWidget {
  final String jobId;
  final String status;
  final dynamic createdAt;

  const _JobStatusCard({
    required this.jobId,
    required this.status,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _statusColor(status).withValues(alpha: .1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              _statusIcon(status),
              color: _statusColor(status),
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: _statusColor(status),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(createdAt),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            jobId.length > 8 ? '#${jobId.substring(0,8)}' : '#$jobId',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return AppTheme.primary;
      case 'PROCESSING':
        return AppTheme.primary;
      case 'QUEUED':
        return AppTheme.secondary;
      case 'FAILED':
        return Colors.red;
      default:
        return AppTheme.secondary;
    }
  }

  static IconData _statusIcon(String status) {
    switch (status) {
      case 'COMPLETED':
        return LucideIcons.checkCircle2;
      case 'PROCESSING':
        return LucideIcons.loader;
      case 'QUEUED':
        return LucideIcons.clock3;
      case 'FAILED':
        return LucideIcons.alertCircle;
      default:
        return LucideIcons.activity;
    }
  }

  static String _formatDate(dynamic value) {
    if (value == null) return 'Date unavailable';

    final date = DateTime.tryParse(value.toString())?.toLocal();
    if (date == null) return 'Date unavailable';

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

    final hour = date.hour == 0
        ? 12
        : date.hour > 12
        ? date.hour - 12
        : date.hour;

    final minute = date.minute.toString().padLeft(2,'0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '${months[date.month - 1]} ${date.day}, ${date.year} • $hour:$minute $period';
  }
}

class _NutrientToggles extends StatelessWidget {
  const _NutrientToggles();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _ToggleButton(
          label: 'Nitrogen (N)',
          isActive: true,
          icon: LucideIcons.flaskConical,
        ),
        const SizedBox(height: 12),
        const _ToggleButton(
          label: 'Phosphorous (P)',
          icon: LucideIcons.droplets,
        ),
        const SizedBox(height: 12),
        const _ToggleButton(
          label: 'Potassium (K)',
          icon: LucideIcons.database,
        ),
        const SizedBox(height: 12),
        const _ToggleButton(
          label: 'Organic Carbon (OC)',
          icon: LucideIcons.leaf,
        ),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final IconData icon;

  const _ToggleButton({
    required this.label,
    required this.icon,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primary : AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isActive
            ? null
            : [
          BoxShadow(
            color: Colors.black.withValues(alpha: .02),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : AppTheme.primary,
                size: 20,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : AppTheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (isActive)
            const Text(
              'Active',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}

class _ConcentrationIndex extends StatelessWidget {
  const _ConcentrationIndex();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CONCENTRATION INDEX',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: AppTheme.secondary,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFED3C7),
                  Color(0xFFA5D0B9),
                  Color(0xFF012D1D),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DEFICIENT',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              Text(
                'OPTIMAL',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              Text(
                'SATURATED',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(
            height: 1,
            color: AppTheme.background,
          ),
          const SizedBox(height: 24),
          const _StatRow(
            label: 'Avg. Concentration',
            value: '42.8 mg/kg',
          ),
          const SizedBox(height: 12),
          const _StatRow(
            label: 'Field Uniformity',
            value: '78%',
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }
}

class _NutrientGrid extends StatelessWidget {
  const _NutrientGrid();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          color: Colors.white,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 12,
            ),
            itemCount: 144,
            itemBuilder: (context,index) {
              final opacity = (index % 7) / 10 + 0.1;
              final isSelected = index == 65;

              return Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary
                      : AppTheme.primary.withValues(alpha: opacity),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .2),
                    width: .5,
                  ),
                ),
                child: isSelected
                    ? const Center(
                  child: Text(
                    '54.2',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 6,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                    : null,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AnalysisResult extends StatelessWidget {
  final String status;
  final Map<String,dynamic> result;

  const _AnalysisResult({
    required this.status,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    if (status == 'QUEUED' || status == 'PROCESSING') {
      return _ResultMessage(
        icon: LucideIcons.loader,
        title: 'Analysis in progress',
        description: status == 'QUEUED'
            ? 'This soil analysis is queued and waiting to be processed.'
            : 'Your soil readings are currently being analysed.',
      );
    }

    if (status == 'FAILED') {
      return const _ResultMessage(
        icon: LucideIcons.alertCircle,
        title: 'Analysis failed',
        description: 'The soil analysis could not be completed.',
        danger: true,
      );
    }

    if (result.isEmpty) {
      return const _ResultMessage(
        icon: LucideIcons.info,
        title: 'Result unavailable',
        description: 'The job is completed but no analysis result was returned.',
      );
    }

    final entries = _resultEntries(result);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                LucideIcons.clipboardCheck,
                color: AppTheme.primary,
                size: 22,
              ),
              SizedBox(width: 12),
              Text(
                'SOIL ANALYSIS RESULT',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: AppTheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          ...List.generate(entries.length,(index) {
            final entry = entries[index];

            return Column(
              children: [
                _ResultRow(
                  label: entry.key,
                  value: entry.value,
                ),
                if (index != entries.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Divider(
                      height: 1,
                      color: AppTheme.background,
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  static List<MapEntry<String,String>> _resultEntries(Map<String,dynamic> result) {
    final preferredKeys = [
      'nitrogenLevel',
      'phosphorousLevel',
      'potassiumLevel',
      'organicCarbonLevel',
      'ironLevel',
      'zincLevel',
      'manganeseLevel',
      'copperLevel',
      'boronLevel',
      'sulphurLevel',
      'salinityLevel',
      'electricalConductivity',
      'pH',
    ];

    final entries = <MapEntry<String,String>>[];

    for (final key in preferredKeys) {
      if (!result.containsKey(key) || result[key] == null) continue;

      entries.add(
        MapEntry(
          _displayName(key),
          _displayValue(result[key]),
        ),
      );
    }

    for (final entry in result.entries) {
      if (preferredKeys.contains(entry.key) || entry.value == null) continue;
      if (entry.value is Map || entry.value is List) continue;

      entries.add(
        MapEntry(
          _displayName(entry.key),
          _displayValue(entry.value),
        ),
      );
    }

    return entries;
  }

  static String _displayName(String key) {
    switch (key) {
      case 'nitrogenLevel':
        return 'Nitrogen';
      case 'phosphorousLevel':
        return 'Phosphorous';
      case 'potassiumLevel':
        return 'Potassium';
      case 'organicCarbonLevel':
        return 'Organic Carbon';
      case 'ironLevel':
        return 'Iron';
      case 'zincLevel':
        return 'Zinc';
      case 'manganeseLevel':
        return 'Manganese';
      case 'copperLevel':
        return 'Copper';
      case 'boronLevel':
        return 'Boron';
      case 'sulphurLevel':
        return 'Sulphur';
      case 'salinityLevel':
        return 'Salinity';
      case 'electricalConductivity':
        return 'Electrical Conductivity';
      case 'pH':
        return 'pH';
      default:
        return _humanize(key);
    }
  }

  static String _displayValue(dynamic value) {
    if (value is bool) return value ? 'YES' : 'NO';
    return value.toString().replaceAll('_',' ').toUpperCase();
  }

  static String _humanize(String value) {
    final spaced = value.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
          (match) => '${match.group(1)} ${match.group(2)}',
    );

    if (spaced.isEmpty) return spaced;

    return '${spaced[0].toUpperCase()}${spaced.substring(1)}';
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final color = _valueColor(value);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurface,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .09),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: .8,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  static Color _valueColor(String value) {
    final normalized = value.toUpperCase();

    if (normalized.contains('LOW') ||
        normalized.contains('DEFICIENT') ||
        normalized.contains('ACIDIC') ||
        normalized.contains('SALINE')) {
      return Colors.orange;
    }

    if (normalized.contains('HIGH') ||
        normalized.contains('BASIC')) {
      return Colors.red;
    }

    if (normalized.contains('MEDIUM') ||
        normalized.contains('OPTIMAL') ||
        normalized.contains('SUFFICIENT') ||
        normalized.contains('NEUTRAL') ||
        normalized.contains('NON-SALINE')) {
      return AppTheme.primary;
    }

    return AppTheme.secondary;
  }
}

class _ResultMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool danger;

  const _ResultMessage({
    required this.icon,
    required this.title,
    required this.description,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? Colors.red : AppTheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: AppTheme.onSurfaceVariant,
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
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.alertCircle,
                color: Colors.red,
                size: 32,
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to load analysis',
                style: TextStyle(
                  fontSize: 17,
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
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(LucideIcons.refreshCw),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildHeader(String status) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              status == 'COMPLETED'
                  ? 'COMPLETED ANALYSIS'
                  : 'REAL-TIME ANALYSIS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF77574D).withValues(alpha: .8),
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Soil Nutrient Map',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Color(0xFF012D1D),
                letterSpacing: -.8,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}