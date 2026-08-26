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
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.horizontalSpacing),
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildHeader(),
            const SizedBox(height: 20),
            const _NutrientToggles(),
            const SizedBox(height: 24),
            const _ConcentrationIndex().animate().fadeIn(delay: 200.ms).moveY(begin: 20, end: 0),
            const SizedBox(height: 32),
            const _NutrientGrid().animate().scale(delay: 400.ms),
            const SizedBox(height: 32),
            const _StressAlert().animate().shake(delay: 800.ms),
            const SizedBox(height: 120),
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
        const SizedBox(height: 12),
        _ToggleButton(label: 'Phosphorus (P)', icon: LucideIcons.droplets),
        const SizedBox(height: 12),
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
      padding: const EdgeInsets.all(20),
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
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppTheme.secondary),
          ),
          const SizedBox(height: 20),
          Container(
            height: 12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: const LinearGradient(
                colors: [Color(0xFFFED3C7), Color(0xFFA5D0B9), Color(0xFF012D1D)],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('DEFICIENT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant)),
              Text('OPTIMAL', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant)),
              Text('SATURATED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: AppTheme.background),
          const SizedBox(height: 24),
          const _StatRow(label: 'Avg. Concentration', value: '42.8 mg/kg'),
          const SizedBox(height: 12),
          const _StatRow(label: 'Field Uniformity', value: '78%'),
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
        Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primary)),
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
                  ? const Center(child: Text('54.2', style: TextStyle(color: Colors.white, fontSize: 6, fontWeight: FontWeight.bold))) 
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: Colors.red, radius: 4),
              SizedBox(width: 8),
              Text('Nitrogen Stress Alert', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Low concentration detected in Sector 4B. Recommended application: 24kg/ha.',
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
          Text("REAL-TIME ANALYSIS", style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF77574D).withOpacity(0.8),
              letterSpacing: 1.1
          )),
          const SizedBox(height: 4),
          Text("Soil Nutrient Map", style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF012D1D),
              letterSpacing: -0.8
          )),
        ],
      ),
    ],
  );
}