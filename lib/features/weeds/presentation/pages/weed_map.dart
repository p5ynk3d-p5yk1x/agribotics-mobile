import 'package:agribotics/core/localization/localized_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';

class WeedMap extends StatelessWidget {
  const WeedMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: AppTheme.horizontalSpacing),
        child: Column(
          children: [
            SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trText('SOIL & FLORA'),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 3.0, color: AppTheme.secondary),
                    ),
                    SizedBox(height: 8),
                    Text(
                      trText('Intelligence'),
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ],
                ),
                Icon(LucideIcons.maximize, color: AppTheme.primary),
              ],
            ),
            SizedBox(height: 48),
            _FloraHeatmap(),
            SizedBox(height: 32),
            _YieldRiskSection(),
            SizedBox(height: 48),
            _PrecisionInterventionCard(),
            SizedBox(height: 48),
            _SpeciesIdentificationSection(),
            SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

class _FloraHeatmap extends StatelessWidget {
  const _FloraHeatmap();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(trText('DENSITY INDEX'), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            Text(trText('SECTION 7B ACTIVE'), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primary, letterSpacing: 1.0)),
          ],
        ),
        SizedBox(height: 24),
        GestureDetector(
          onTap: () => context.go('/sector-detail'),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: AspectRatio(
              aspectRatio: 1,
              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 15),
                itemCount: 225,
                itemBuilder: (context, index) {
                  final opacity = (index % 11) / 12 + 0.1;
                  return Container(
                    color: AppTheme.primary.withOpacity(opacity),
                    margin: EdgeInsets.all(0.2),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _YieldRiskSection extends StatelessWidget {
  const _YieldRiskSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(trText('YIELD RISK'), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.secondary, letterSpacing: 1.5)),
            SizedBox(height: 4),
            Row(
              children: [
                Text(trText('-14.2%'), style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: AppTheme.onSurface)),
                SizedBox(width: 12),
                Icon(LucideIcons.trendingDown, color: Colors.orange, size: 24),
              ],
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(100)),
          child: Text(trText('ATTENTION REQUIRED'), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.orange, letterSpacing: 1.0)),
        ),
      ],
    );
  }
}

class _PrecisionInterventionCard extends StatelessWidget {
  const _PrecisionInterventionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(trText('PRECISION INTERVENTION'), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white54, letterSpacing: 2.0)),
              Icon(LucideIcons.zap, color: Colors.white, size: 20),
            ],
          ),
          SizedBox(height: 48),
          Text(
            trText('Invasive Species\nNeutralization.'),
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1),
          ),
          SizedBox(height: 24),
          Text(
            trText('Targeted application of organic herbicide required in high-density pockets.'),
            style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
          ),
          SizedBox(height: 48),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primary,
              minimumSize: Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
            ),
            child: Text(trText('Initialize Protocol'), style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _SpeciesIdentificationSection extends StatelessWidget {
  const _SpeciesIdentificationSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          trText('SPECIES IDENTIFICATION'),
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 3.0, color: AppTheme.secondary),
        ),
        SizedBox(height: 32),
        _SpeciesItem(
          name: 'Palmer Amaranth',
          count: 124,
          risk: 'HIGH',
          riskColor: Colors.red,
          onTap: () => context.go('/weed/detail'),
        ),
        SizedBox(height: 24),
        _SpeciesItem(name: 'Waterhemp', count: 82, risk: 'MEDIUM', riskColor: Colors.orange),
        SizedBox(height: 24),
        _SpeciesItem(name: 'Foxtail', count: 215, risk: 'LOW', riskColor: Colors.grey),
      ],
    );
  }
}

class _SpeciesItem extends StatelessWidget {
  final String name;
  final int count;
  final String risk;
  final Color riskColor;
  final VoidCallback? onTap;

  const _SpeciesItem({required this.name, required this.count, required this.risk, required this.riskColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(24)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(12)),
                  child: Icon(LucideIcons.leaf, color: AppTheme.primary, size: 20),
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(trText(name), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(trText('$count Detection Points'), style: TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(trText('DRIVE RISK'), style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                Text(trText(risk), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: riskColor)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
