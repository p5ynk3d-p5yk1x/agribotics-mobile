import 'package:agribotics/core/localization/localized_text.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';

class SoilNutrientMap extends StatelessWidget {
  const SoilNutrientMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppTheme.horizontalSpacing),
        child: Column(
          children: [
            SizedBox(height: 40),
            _buildHeader(),
            SizedBox(height: 20),
            _NutrientToggles(),
            SizedBox(height: 24),
            _ConcentrationIndex().animate().fadeIn(delay: 200.ms).moveY(begin: 20, end: 0),
            SizedBox(height: 32),
            _NutrientGrid().animate().scale(delay: 400.ms),
            SizedBox(height: 32),
            _StressAlert().animate().shake(delay: 800.ms),
            SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

class _NutrientToggles extends StatelessWidget {
  const _NutrientToggles();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ToggleButton(label: 'Nitrogen (N)', isActive: true, icon: LucideIcons.flaskConical),
        SizedBox(height: 12),
        _ToggleButton(label: 'Phosphorus (P)', icon: LucideIcons.droplets),
        SizedBox(height: 12),
        _ToggleButton(label: 'Potassium (K)', icon: LucideIcons.database),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final IconData icon;

  const _ToggleButton({required this.label, required this.icon, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primary : AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isActive ? null : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: isActive ? Colors.white : AppTheme.primary, size: 20),
              SizedBox(width: 16),
              Text(
                trText(label),
                style: TextStyle(
                  color: isActive ? Colors.white : AppTheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (isActive)
            Text(
              trText('Active'),
              style: TextStyle(color: Colors.white70, fontSize: 12),
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
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            trText('CONCENTRATION INDEX'),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppTheme.secondary),
          ),
          SizedBox(height: 20),
          Container(
            height: 12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: LinearGradient(
                colors: [Color(0xFFFED3C7), Color(0xFFA5D0B9), Color(0xFF012D1D)],
              ),
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(trText('DEFICIENT'), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant)),
              Text(trText('OPTIMAL'), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant)),
              Text(trText('SATURATED'), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant)),
            ],
          ),
          SizedBox(height: 24),
          Divider(height: 1, color: AppTheme.background),
          SizedBox(height: 24),
          _StatRow(label: 'Avg. Concentration', value: '42.8 mg/kg'),
          SizedBox(height: 12),
          _StatRow(label: 'Field Uniformity', value: '78%'),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(trText(label), style: TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant)),
        Text(trText(value), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primary)),
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
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 12,
            ),
            itemCount: 144,
            itemBuilder: (context, index) {
              // Mock heatmap distribution
              final opacity = (index % 7) / 10 + 0.1;
              final isSelected = index == 65;

              return Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : AppTheme.primary.withOpacity(opacity),
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
                ),
                child: isSelected
                  ? Center(child: Text(trText('54.2'), style: TextStyle(color: Colors.white, fontSize: 6, fontWeight: FontWeight.bold)))
                  : null,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StressAlert extends StatelessWidget {
  const _StressAlert();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: Colors.red, radius: 4),
              SizedBox(width: 8),
              Text(trText('Nitrogen Stress Alert'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          SizedBox(height: 12),
          Text(
            trText('Low concentration detected in Sector 4B. Recommended application: 24kg/ha.'),
            style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant, height: 1.5),
          ),
        ],
      ),
    );
  }
}

Widget _buildHeader() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(trText("REAL-TIME ANALYSIS"), style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF77574D).withOpacity(0.8),
              letterSpacing: 1.1
          )),
          SizedBox(height: 4),
          Text(trText("Soil Nutrient Map"), style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF012D1D),
              letterSpacing: -0.8
          )),
        ],
      ),
    ],
  );
}