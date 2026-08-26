import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';

class SectorDetailPage extends StatelessWidget {
  const SectorDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Sector 7-B Detail'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.horizontalSpacing),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const _GridFocusSection(),
            const SizedBox(height: 48),
            const _SpeciesGridListHeader(),
            const SizedBox(height: 24),
            _SpeciesDensityItem(
              name: 'Palmer Amaranth',
              density: 'High',
              code: 'PA-01',
              onTap: () => context.go('/weed/detail'),
            ),
            const SizedBox(height: 12),
            const _SpeciesDensityItem(name: 'Giant Foxtail', density: 'Moderate', code: 'GF-02'),
            const SizedBox(height: 48),
            const _ProtocolRecommendationCard(),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

class _GridFocusSection extends StatelessWidget {
  const _GridFocusSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('GRID FOCUS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppTheme.secondary)),
            const Text('COORD: 45.521, -122.678', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primary)),
          ],
        ),
        const SizedBox(height: 24),
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppTheme.outline.withOpacity(0.1)),
            ),
            padding: const EdgeInsets.all(2),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
              itemCount: 25,
              itemBuilder: (context, index) {
                final isSelected = index == 12;
                final hasDetection = index == 7 || index == 18;
                
                return Container(
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : (hasDetection ? Colors.red.withOpacity(0.1) : AppTheme.background),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: hasDetection 
                      ? const Center(child: CircleAvatar(backgroundColor: Colors.red, radius: 3))
                      : (isSelected ? const Center(child: Icon(LucideIcons.target, color: Colors.white, size: 24)) : null),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _SpeciesGridListHeader extends StatelessWidget {
  const _SpeciesGridListHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('SPECIES IN GRID', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppTheme.outline)),
        Text('DENSITY DATA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppTheme.outline)),
      ],
    );
  }
}

class _SpeciesDensityItem extends StatelessWidget {
  final String name;
  final String density;
  final String code;
  final VoidCallback? onTap;

  const _SpeciesDensityItem({required this.name, required this.density, required this.code, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(24)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
                  child: Text(code, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 20),
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            Text(density, style: TextStyle(fontWeight: FontWeight.w900, color: density == 'High' ? Colors.red : Colors.orange)),
          ],
        ),
      ),
    );
  }
}

class _ProtocolRecommendationCard extends StatelessWidget {
  const _ProtocolRecommendationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.primaryContainer,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('RECOMMENDED PROTOCOL', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
          const SizedBox(height: 24),
          const Text(
            'Herbix-Safe™ (Organic Focus)',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 12),
          const Text(
            'Targeted sub-meter spraying of Palmer Amaranth clusters. 2% concentration.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('98.2%', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
                  Text('EST. SUCCESS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 1.0)),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Execute Task'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
