import 'package:agribotics/core/localization/localized_text.dart';
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
        padding: EdgeInsets.symmetric(horizontal: AppTheme.horizontalSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 80),
            Text(
              trText('ANNUAL TERROIR ANALYSIS'),
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 3.0, color: AppTheme.secondary),
            ),
            SizedBox(height: 24),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.black),
                children: [
                  TextSpan(text: trText('Soil ')),
                  TextSpan(
                    text: trText('Vitality'),
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF2D4F35).withOpacity(0.8) // Dark green tone from image
                    ),
                  ),
                ],
              ),
            ),
            Text(
              trText('Report 2024'),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 48),
            _ExpertNoteHeader(),
            SizedBox(height: 48),
            _VitalityScoreCard(),
            SizedBox(height: 16),

            // NPK Section
            _NutrientTile(label: 'NITROGEN (N)', status: 'Optimal', barLevels: [0.4, 0.6, 1.0, 0.8, 0.5]),
            _NutrientTile(label: 'PHOSPHORUS (P)', status: 'Balanced', barLevels: [0.3, 0.5, 0.7, 0.5, 0.3]),
            _NutrientTile(label: 'POTASSIUM (K)', status: 'Rich', barLevels: [0.5, 0.7, 1.0, 0.7, 0.5]),

            SizedBox(height: 48),
            _CuratorNoteSection(),
            SizedBox(height: 64),
            _StrataDiagnosticsSection(),
            SizedBox(height: 120),
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
      padding: EdgeInsets.only(left: 24),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.grey, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            trText('A comprehensive investigation into the chemical and biological strata of the Northern Parcels.'),
            style: TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant, height: 1.6),
          ),
          SizedBox(height: 24),
          Row(
            children: [
              Icon(LucideIcons.calendar, size: 14),
              SizedBox(width: 8),
              Text(trText('OCTOBER UPDATE'), style: Theme.of(context).textTheme.labelLarge),
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
      padding: EdgeInsets.all(40),
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
              Text(trText('VITALITY SCORE'), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2.0, color: Colors.grey)),
              Icon(LucideIcons.leaf, color: Colors.black12, size: 64),
            ],
          ),
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 110, fontWeight: FontWeight.w900, color: Color(0xFF0A2215), height: 1.0),
              children: [
                TextSpan(text: trText('88')),
                TextSpan(text: trText('/100'), style: TextStyle(fontSize: 24, fontWeight: FontWeight.w300, color: Colors.grey)),
              ],
            ),
          ),
          SizedBox(height: 24),
          Text(trText('Exceptional microbial diversity noted in the top 15cm of the rhizosphere.'), style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
          SizedBox(height: 32),
          LinearProgressIndicator(value: 0.88, backgroundColor: Colors.grey.shade200, color: Color(0xFF0A2215), minHeight: 4),
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
        return Color(0xFF0A2215); // Deep Forest Green
      case 'optimal':
        return Color(0xFF2D4F35); // Mid Green
      case 'balanced':
        return Color(0xFF6B8E6B); // Soft Sage
      case 'poor':
        return Color(0xFFB5C9B5); // Pale Green
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(status);

    return Container(
      margin: EdgeInsets.only(top: 16),
      padding: EdgeInsets.all(32), // Increased padding for larger tile size
      decoration: BoxDecoration(
        // Using a soft off-white/grey for a premium "card" feel
        color: Color(0xFFF5F7F5),
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
                trText(label),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.black45,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 8),
              Text(
                trText(status),
                style: TextStyle(
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
                margin: EdgeInsets.symmetric(horizontal: 3),
                width: 8, // Slightly wider bars
                height: 50 * level, // Scaled height
                decoration: BoxDecoration(
                  // Gradient effect: Active bars use status color, others are muted
                  color: level >= 0.7
                      ? statusColor
                      : statusColor.withOpacity(0.3),
                  borderRadius: BorderRadius.vertical(
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
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.7)])),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(trText('RHIZOSPHERE DETAIL'), style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Text(trText('Micro-imaging reveals high levels of mycorrhizal fungi activity near root zones.'), style: TextStyle(color: Colors.white, fontSize: 13)),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Color(0xFF1B3022), shape: BoxShape.circle),
                        child: Icon(LucideIcons.maximize, color: Colors.white, size: 20),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(height: 48),
        Text(trText('CURATOR\'S NOTE'), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 2.0)),
        SizedBox(height: 24),
        Text(
          trText('"The quiet complexity of the soil dictates the volume of the harvest."'),
          style: TextStyle(fontSize: 26, fontStyle: FontStyle.italic, fontWeight: FontWeight.w300, height: 1.3),
        ),
        SizedBox(height: 24),
        Text(
          trText('Upon reviewing the latest core samples from the North-East slope, we\'ve observed a significant increase in organic matter retention. The transition to no-till practices over the last eighteen months is manifesting as a dense, nutrient-rich topsoil layer.'),
          style: TextStyle(color: Colors.black87, height: 1.6),
        ),
        SizedBox(height: 24),
        Text(
          trText('We recommend continuing the current cover-cropping cycle using the crimson clover blend...'),
          style: TextStyle(color: Colors.black87, height: 1.6),
        ),
        SizedBox(height: 32),
        Row(
          children: [
            SizedBox(width: 40, child: Divider(color: Colors.black)),
            SizedBox(width: 12),
            Text(trText('Julian Thorne, '), style: TextStyle(fontWeight: FontWeight.bold)),
            Text(trText('Chief Agronomist'), style: TextStyle(color: Colors.grey)),
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
        Center(child: Text(trText('STRATA DIAGNOSTICS'), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 3.0, color: Colors.grey))),
        SizedBox(height: 64),
        _DiagnosticMetric(value: '6.8', label: 'PH BALANCE', description: 'Perfectly neutral for the intended cool-season cultivars.'),
        SizedBox(height: 48),
        _DiagnosticMetric(value: '4.2%', label: 'ORGANIC MATTER', description: 'An increase of 0.8% YoY, surpassing estate benchmarks.'),
        SizedBox(height: 48),
        _DiagnosticMetric(value: '22%', label: 'MOISTURE RET.', description: 'Healthy water-holding capacity despite the summer dry spell.'),
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
        Text(trText(value), style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text(trText(label), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey)),
        SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(trText(description), textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.5)),
        ),
      ],
    );
  }
}