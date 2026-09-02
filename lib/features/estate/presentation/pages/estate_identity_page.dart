import 'package:agribotics/core/localization/localized_text.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/status_badge.dart';

class EstateIdentityPage extends StatelessWidget {
  const EstateIdentityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppTheme.horizontalSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),
          Text(
            trText('NEW ANALYSIS PHASE'),
            style: Theme.of(context).textTheme.labelLarge,
          ).animate().fadeIn().moveX(begin: -20, end: 0),
          SizedBox(height: 8),
          Text(
            trText('Location &'),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppTheme.onSurface,
                ),
          ).animate().fadeIn(delay: 100.ms),
          Text(
            trText('Estate Identity'),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppTheme.primaryContainer,
                ),
          ).animate().fadeIn(delay: 200.ms),
          SizedBox(height: 24),
          Text(
            trText("Begin your soil's digital transformation. Define the boundaries of your heritage and select the precise coordinate for extraction."),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
          ).animate().fadeIn(delay: 300.ms),
          SizedBox(height: 48),
          _DefineParcelCard(),
          SizedBox(height: 32),
          _EstateImageSection(),
          SizedBox(height: 40),
          _InfoTipsSection(),
          SizedBox(height: 120),
        ],
      ),
    );
  }
}

class _DefineParcelCard extends StatelessWidget {
  const _DefineParcelCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 40,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusBadge(label: 'STEP 01'),
              Icon(LucideIcons.home, color: AppTheme.primary.withOpacity(0.2), size: 32),
            ],
          ),
          SizedBox(height: 24),
          Text(
            trText('Define the Parcel'),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 32),
          _FieldLabel(label: 'ESTATE NAME'),
          SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: 'e.g. Blackwood Highlands',
              hintStyle: TextStyle(color: AppTheme.onSurfaceVariant.withOpacity(0.3)),
              fillColor: AppTheme.background,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            ),
          ),
          SizedBox(height: 32),
          _FieldLabel(label: 'PRIMARY CULTIVAR'),
          SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _CultivarChip(label: 'Vineyard', isActive: true),
              _CultivarChip(label: 'Orchard'),
              _CultivarChip(label: 'Arable'),
              _CultivarChip(label: 'Pasture'),
            ],
          ),
          SizedBox(height: 48),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 64),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(trText('Confirm Location'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                SizedBox(width: 8),
                Icon(LucideIcons.arrowRight, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      trText(label),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.0,
        color: AppTheme.secondary,
      ),
    );
  }
}

class _CultivarChip extends StatelessWidget {
  final String label;
  final bool isActive;
  const _CultivarChip({required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primary : AppTheme.background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        trText(label),
        style: TextStyle(
          color: isActive ? Colors.white : AppTheme.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _EstateImageSection extends StatelessWidget {
  const _EstateImageSection();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: AspectRatio(
            aspectRatio: 4 / 5,
            child: Image.network(
              'https://picsum.photos/seed/estate/800/1000',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 24,
          left: 24,
          right: 24,
          child: Padding(
            padding: EdgeInsets.all(24),
            child: GlassContainer(
              blur: 15,
              opacity: 0.2,
              borderRadius: BorderRadius.circular(20),
              border: Border.fromBorderSide(
                BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(LucideIcons.mapPin, color: Colors.white),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trText('Auto-detecting GPS'),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          trText('45.5231° N, 122.6765° W'),
                          style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              trText('PRECISION LOCK ACTIVE'),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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

class _InfoTipsSection extends StatelessWidget {
  const _InfoTipsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.onSurfaceVariant.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.info, color: AppTheme.secondary),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              trText('Data accuracy is optimized through high-resolution satellite layering and multi-spectral analysis of your specific topography.'),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
