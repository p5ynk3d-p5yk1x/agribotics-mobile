import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';

class DiseasePathogenMapScreen extends StatelessWidget {
  const DiseasePathogenMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24,),
                  Text(
                    'HEALTH ANALYSIS',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.secondary.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.displayMedium,
                      children: const [
                        TextSpan(text: 'Disease Pathogen '),
                        TextSpan(
                          text: 'Map',
                          style: TextStyle(color: Color(0xFF1B4332)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTopMetrics(),
                  const SizedBox(height: 32),
                  _buildDiseaseMap(),
                  const SizedBox(height: 48),
                  _buildLiveFieldLogsHeader(),
                  const SizedBox(height: 16),
                  _buildLogCard(
                    context,
                    icon: LucideIcons.alertTriangle,
                    title: 'Fusarium Wilt detected in Southwest quadrant',
                    subtitle: 'High humidity levels (82%) coupled with soil moisture triggers rapid pathogen germination.',
                    label: 'Warning',
                    meta: 'BLOCK 4A • 14:22',
                    actionLabel: 'View Remediation',
                    accentColor: const Color(0xFF77574D),
                  ),
                  _buildLogCard(
                    context,
                    icon: LucideIcons.maximize,
                    title: 'Secondary Infection Vector: Late Blight',
                    subtitle: 'Foliage analysis shows 15% degradation. Immediate copper-based application recommended.',
                    label: 'High Priority',
                    meta: 'BLOCK 2C • 12:05',
                    actionLabel: 'Issue Directive',
                    accentColor: const Color(0xFF77574D),
                  ),
                  _buildLogCard(
                    context,
                    icon: LucideIcons.checkCircle,
                    title: 'Successful Eradication in Sector 7',
                    subtitle: 'Pathogen count dropped below threshold following targeted ozone treatment cycle.',
                    label: 'Check',
                    meta: 'BLOCK 7 • 09:10',
                    actionLabel: 'Review Full History',
                    accentColor: AppTheme.primary,
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildTopMetrics() {
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
                Text('PATHOGEN PRESSURE ESTIMATOR',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: AppTheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                          color: Color(0xFF77574D), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text('Moderate Risk',
                        style: GoogleFonts.manrope(
                            fontSize: 20, fontWeight: FontWeight.w700)),
                  ],
                )
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
                Text('PATHOGEN INDEX',
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white60)),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: '42',
                          style: GoogleFonts.manrope(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                      TextSpan(
                          text: '/100',
                          style: GoogleFonts.manrope(
                              fontSize: 14, color: Colors.white70)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiseaseMap() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: AspectRatio(
        aspectRatio: 1,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 15),
          itemCount: 225,
          itemBuilder: (context, index) {
            final opacity = (index % 11) / 12 + 0.1;
            return Container(
              color: AppTheme.primary.withOpacity(opacity),
              margin: const EdgeInsets.all(0.2),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLiveFieldLogsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Live Field Logs',
            style: GoogleFonts.manrope(
                fontSize: 28, fontWeight: FontWeight.w800)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F4F2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('4 CRITICAL ALERTS',
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF77574D))),
        )
      ],
    );
  }

  Widget _buildLogCard(BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required String label,
        required String meta,
        required String actionLabel,
        required Color accentColor,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 24,
                      color: accentColor.withOpacity(0.7),
                      fontWeight: FontWeight.w300)),
              Text(meta,
                  style: GoogleFonts.inter(
                      fontSize: 10, color: AppTheme.onSurfaceVariant)),
            ],
          ),
          const SizedBox(height: 16),
          Text(title,
              style: GoogleFonts.manrope(
                  fontSize: 18, fontWeight: FontWeight.w700, height: 1.2)),
          const SizedBox(height: 12),
          Text(subtitle,
              style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.onSurfaceVariant,
                  height: 1.5)),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(actionLabel,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(width: 4),
              const Icon(LucideIcons.arrowRight, size: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 8),
          Text(text, style: GoogleFonts.inter(fontSize: 10)),
        ],
      ),
    );
  }
}