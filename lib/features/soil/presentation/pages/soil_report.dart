import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';

class SoilReport extends StatelessWidget {
  const SoilReport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.horizontalSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            const Text(
              'ANNUAL TERROIR ANALYSIS',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 3.0, color: AppTheme.secondary),
            ),
            const SizedBox(height: 24),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.black),
                children: [
                  const TextSpan(text: 'Soil '),
                  TextSpan(
                    text: 'Vitality',
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w300,
                        color: const Color(0xFF2D4F35).withOpacity(0.8) // Dark green tone from image
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Report 2024',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 48),
            const _ExpertNoteHeader(),
            const SizedBox(height: 48),
            const _VitalityScoreCard(),
            const SizedBox(height: 16),

            // NPK Section
            const _NutrientTile(label: 'NITROGEN (N)', status: 'Optimal', barLevels: [0.4, 0.6, 1.0, 0.8, 0.5]),
            const _NutrientTile(label: 'PHOSPHORUS (P)', status: 'Balanced', barLevels: [0.3, 0.5, 0.7, 0.5, 0.3]),
            const _NutrientTile(label: 'POTASSIUM (K)', status: 'Rich', barLevels: [0.5, 0.7, 1.0, 0.7, 0.5]),

            const SizedBox(height: 48),
            const _CuratorNoteSection(),
            const SizedBox(height: 64),
            const _StrataDiagnosticsSection(),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

// --- Header Section ---
class _ExpertNoteHeader extends StatelessWidget {
  const _ExpertNoteHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 24),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'A comprehensive investigation into the chemical and biological strata of the Northern Parcels.',
            style: TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant, height: 1.6),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(LucideIcons.calendar, size: 14),
              const SizedBox(width: 8),
              Text('OCTOBER UPDATE', style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Score Card ---
class _VitalityScoreCard extends StatelessWidget {
  const _VitalityScoreCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('VITALITY SCORE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: Colors.grey)),
              Icon(LucideIcons.leaf, color: Colors.black12, size: 64),
            ],
          ),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 110, fontWeight: FontWeight.w900, color: Color(0xFF0A2215), height: 1.0),
              children: [
                TextSpan(text: '88'),
                TextSpan(text: '/100', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Exceptional microbial diversity noted in the top 15cm of the rhizosphere.', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
          const SizedBox(height: 32),
          LinearProgressIndicator(value: 0.88, backgroundColor: Colors.grey.shade200, color: const Color(0xFF0A2215), minHeight: 4),
        ],
      ),
    );
  }
}

// --- Nutrient Tiles (NPK) ---
// --- Updated Nutrient Tile with Gradient & Bottom Alignment ---
class _NutrientTile extends StatelessWidget {
  final String label;
  final String status;
  final List<double> barLevels;

  const _NutrientTile({
    required this.label,
    required this.status,
    required this.barLevels,
  });

  // Helper to determine the color gradient based on soil status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'rich':
        return const Color(0xFF0A2215); // Deep Forest Green
      case 'optimal':
        return const Color(0xFF2D4F35); // Mid Green
      case 'balanced':
        return const Color(0xFF6B8E6B); // Soft Sage
      case 'poor':
        return const Color(0xFFB5C9B5); // Pale Green
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(32), // Increased padding for larger tile size
      decoration: BoxDecoration(
        // Using a soft off-white/grey for a premium "card" feel
        color: const Color(0xFFF5F7F5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end, // Aligns content to the bottom
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black45,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                status,
                style: const TextStyle(
                  fontSize: 24, // Increased font size
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0A2215),
                ),
              ),
            ],
          ),
          // Bar chart section
          Row(
            crossAxisAlignment: CrossAxisAlignment.end, // Forces bars to align to the bottom
            children: List.generate(barLevels.length, (index) {
              final double level = barLevels[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 8, // Slightly wider bars
                height: 50 * level, // Scaled height
                decoration: BoxDecoration(
                  // Gradient effect: Active bars use status color, others are muted
                  color: level >= 0.7
                      ? statusColor
                      : statusColor.withOpacity(0.3),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              );
            }),
          )
        ],
      ),
    );
  }
}

// --- Curator Note & Image Section ---
class _CuratorNoteSection extends StatelessWidget {
  const _CuratorNoteSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              Image.network('https://images.unsplash.com/photo-1592982537447-7440770cbfc9?q=80&w=2000', height: 350, width: double.infinity, fit: BoxFit.cover),
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.7)])),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('RHIZOSPHERE DETAIL', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Text('Micro-imaging reveals high levels of mycorrhizal fungi activity near root zones.', style: TextStyle(color: Colors.white, fontSize: 13)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(color: Color(0xFF1B3022), shape: BoxShape.circle),
                        child: const Icon(LucideIcons.maximize, color: Colors.white, size: 20),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 48),
        const Text('CURATOR\'S NOTE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 2.0)),
        const SizedBox(height: 24),
        const Text(
          '"The quiet complexity of the soil dictates the volume of the harvest."',
          style: TextStyle(fontSize: 26, fontStyle: FontStyle.italic, fontWeight: FontWeight.w300, height: 1.3),
        ),
        const SizedBox(height: 24),
        const Text(
          'Upon reviewing the latest core samples from the North-East slope, we\'ve observed a significant increase in organic matter retention. The transition to no-till practices over the last eighteen months is manifesting as a dense, nutrient-rich topsoil layer.',
          style: TextStyle(color: Colors.black87, height: 1.6),
        ),
        const SizedBox(height: 24),
        const Text(
          'We recommend continuing the current cover-cropping cycle using the crimson clover blend...',
          style: TextStyle(color: Colors.black87, height: 1.6),
        ),
        const SizedBox(height: 32),
        const Row(
          children: [
            SizedBox(width: 40, child: Divider(color: Colors.black)),
            SizedBox(width: 12),
            Text('Julian Thorne, ', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Chief Agronomist', style: TextStyle(color: Colors.grey)),
          ],
        )
      ],
    );
  }
}

// --- Strata Diagnostics (Vertical Column) ---
class _StrataDiagnosticsSection extends StatelessWidget {
  const _StrataDiagnosticsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Center(child: Text('STRATA DIAGNOSTICS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 3.0, color: Colors.grey))),
        const SizedBox(height: 64),
        const _DiagnosticMetric(value: '6.8', label: 'PH BALANCE', description: 'Perfectly neutral for the intended cool-season cultivars.'),
        const SizedBox(height: 48),
        const _DiagnosticMetric(value: '4.2%', label: 'ORGANIC MATTER', description: 'An increase of 0.8% YoY, surpassing estate benchmarks.'),
        const SizedBox(height: 48),
        const _DiagnosticMetric(value: '22%', label: 'MOISTURE RET.', description: 'Healthy water-holding capacity despite the summer dry spell.'),
      ],
    );
  }
}

class _DiagnosticMetric extends StatelessWidget {
  final String value;
  final String label;
  final String description;

  const _DiagnosticMetric({required this.value, required this.label, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey)),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.5)),
        ),
      ],
    );
  }
}