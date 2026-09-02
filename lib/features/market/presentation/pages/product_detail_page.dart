import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/marketplace_models.dart';
import '../../data/marketplace_providers.dart';

class ProductDetailPage extends ConsumerWidget {
  final String productId;
  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(marketplaceProductProvider(productId));
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: product.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ProductError(
          onRetry: () => ref.invalidate(marketplaceProductProvider(productId)),
        ),
        data: (product) => _ProductContent(product: product),
      ),
    );
  }
}

class _ProductContent extends StatelessWidget {
  final MarketplaceProduct product;
  const _ProductContent({required this.product});

  Future<void> _openAffiliateUrl(BuildContext context) async {
    final uri = Uri.tryParse(product.affiliateUrl);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid product link.')),
      );
      return;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open product link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.horizontalSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 64),
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(LucideIcons.arrowLeft),
          ),
          const SizedBox(height: 20),
          _ProductHeroImage(imageUrl: product.imageUrl).animate().fadeIn().scale(begin: const Offset(0.98, 0.98)),
          const SizedBox(height: 32),
          if (product.category != null)
            Text(
              product.category!.label.toUpperCase(),
              style: Theme.of(context).textTheme.labelLarge,
            ).animate().fadeIn(),
          const SizedBox(height: 10),
          Text(
            product.name,
            style: Theme.of(context).textTheme.displayLarge,
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 16),
          Text(
            product.formattedPrice,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppTheme.secondary,
            ),
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: 32),
          const Text(
            'PRODUCT DETAILS',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 1.4,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            product.description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.6,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          if (product.problemKeywords.isNotEmpty) ...[
            const SizedBox(height: 36),
            const Text(
              'RECOMMENDED FOR',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1.4,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: product.problemKeywords.map((keyword) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    keyword,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 44),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openAffiliateUrl(context),
              icon: const Icon(LucideIcons.externalLink),
              label: const Text('View Product'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(58),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}

class _ProductHeroImage extends StatelessWidget {
  final String? imageUrl;
  const _ProductHeroImage({this.imageUrl});

  String? _formatImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;

    return url.replaceFirst(
      'http://localhost:3000',
      'http://192.168.1.177:3000',
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedUrl = _formatImageUrl(imageUrl);

    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: formattedUrl == null
            ? const ColoredBox(
          color: AppTheme.surface,
          child: Center(
            child: Icon(
              LucideIcons.image,
              size: 56,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        )
            : Image.network(
          formattedUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return const ColoredBox(
              color: AppTheme.surface,
              child: Center(
                child: Icon(
                  LucideIcons.imageOff,
                  size: 56,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProductError extends StatelessWidget {
  final VoidCallback onRetry;
  const _ProductError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.alertCircle, size: 44, color: AppTheme.onSurfaceVariant),
            const SizedBox(height: 16),
            const Text(
              'Unable to load this product.',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}