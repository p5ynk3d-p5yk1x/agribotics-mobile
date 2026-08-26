import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';

class MarketPage extends StatelessWidget {
  const MarketPage({super.key});

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
            Text(
              'CURATED INPUTS',
              style: Theme.of(context).textTheme.labelLarge,
            ).animate().fadeIn().moveX(begin: -20, end: 0),
            const SizedBox(height: 8),
            Text(
              'Marketplace',
              style: Theme.of(context).textTheme.displayLarge,
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 24),
            const Text(
              'Premium soil amendments and biological agents tailored for your estate metrics.',
              style: TextStyle(fontSize: 16, color: AppTheme.onSurfaceVariant, height: 1.5),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 48),
            const _PromoCard(),
            const SizedBox(height: 48),
            const _CategoryFilter(),
            const SizedBox(height: 32),
            const _ProductGrid(),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220, // Increased slightly to give the design more "breathability"
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(32),
        image: const DecorationImage(
          image: NetworkImage('https://picsum.photos/seed/market/800/400'),
          fit: BoxFit.cover,
          opacity: 0.4,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24), // Reduced padding slightly from 32
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Flexible(
              child: Text(
                'Seasonal\nNutrient Prep.',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Save 15% on winter reserves.', // Shortened text slightly
              style: TextStyle(color: Colors.white70),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              ),
              child: const Text('Shop Offer'),
            ),
          ],
        ),
      ),
    ).animate().scale(delay: 600.ms, curve: Curves.easeOutBack);
  }
}
class _CategoryFilter extends StatelessWidget {
  const _CategoryFilter();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _CatChip(label: 'All Inputs', isActive: true),
          _CatChip(label: 'Bio-Agents'),
          _CatChip(label: 'Minerals'),
          _CatChip(label: 'Equipment'),
          _CatChip(label: 'Seeds'),
        ],
      ),
    );
  }
}

class _CatChip extends StatelessWidget {
  final String label;
  final bool isActive;
  const _CatChip({required this.label, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primary : AppTheme.surface,
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

class _ProductGrid extends StatelessWidget {
  const _ProductGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: 0.7,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        final titles = ['N-Boost Elite', 'Phos-Flow', 'K-Pure 500', 'Bio-Defense'];
        final prices = ['£124.00', '£89.50', '£215.00', '£156.00'];
        
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(
                    'https://picsum.photos/seed/prod$index/400/400',
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titles[index], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(prices[index], style: const TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: (800 + (index * 100)).ms).moveY(begin: 20, end: 0);
      },
    );
  }
}
