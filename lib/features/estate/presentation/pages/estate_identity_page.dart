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
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.horizontalSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Text(
            'NEW ANALYSIS PHASE',
            style: Theme.of(context).textTheme.labelLarge,
          ).animate().fadeIn().moveX(begin: -20, end: 0),
          const SizedBox(height: 8),
          Text(
            'Location &',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppTheme.onSurface,
                ),
          ).animate().fadeIn(delay: 100.ms),
          Text(
            'Estate Identity',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppTheme.primaryContainer,
                ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 24),
          Text(
            "Begin your soil's digital transformation. Define the boundaries of your heritage and select the precise coordinate for extraction.",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 48),
          const _DefineParcelCard(),
          const SizedBox(height: 32),
          const _EstateImageSection(),
          const SizedBox(height: 40),
          const _InfoTipsSection(),
          const SizedBox(height: 120),
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
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const StatusBadge(label: 'STEP 01'),
              Icon(LucideIcons.home, color: AppTheme.primary.withOpacity(0.2), size: 32),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Define the Parcel',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 32),
          _FieldLabel(label: 'ESTATE NAME'),
          const SizedBox(height: 12),
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            ),
          ),
          const SizedBox(height: 32),
          _FieldLabel(label: 'PRIMARY CULTIVAR'),
          const SizedBox(height: 12),
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
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 64),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Confirm Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(width: 8),
                const Icon(LucideIcons.arrowRight, size: 20),
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
      label,
      style: const TextStyle(
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primary : AppTheme.background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
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
            padding: const EdgeInsets.all(24),
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(LucideIcons.mapPin, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Auto-detecting GPS',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '45.5231° N, 122.6765° W',
                          style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
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
                            const SizedBox(width: 8),
                            const Text(
                              'PRECISION LOCK ACTIVE',
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.onSurfaceVariant.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(LucideIcons.info, color: AppTheme.secondary),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Data accuracy is optimized through high-resolution satellite layering and multi-spectral analysis of your specific topography.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
