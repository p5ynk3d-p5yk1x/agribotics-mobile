import 'package:agribotics/core/localization/localized_text.dart';
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
        loading: () => Center(child: CircularProgressIndicator()),
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
        SnackBar(content: Text(trText('Invalid product link.'))),
      );
      return;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(trText('Unable to open product link.'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: AppTheme.horizontalSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 64),
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(LucideIcons.arrowLeft),
          ),
          SizedBox(height: 20),
          _ProductHeroImage(imageUrl: product.imageUrl).animate().fadeIn().scale(begin: Offset(0.98, 0.98)),
          SizedBox(height: 32),
          if (product.category != null)
            Text(
              trText(product.category!.label.toUpperCase()),
              style: Theme.of(context).textTheme.labelLarge,
            ).animate().fadeIn(),
          SizedBox(height: 10),
          Text(
            trText(product.name),
            style: Theme.of(context).textTheme.displayLarge,
          ).animate().fadeIn(delay: 100.ms),
          SizedBox(height: 16),
          Text(
            trText(product.formattedPrice),
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppTheme.secondary,
            ),
          ).animate().fadeIn(delay: 150.ms),
          SizedBox(height: 32),
          Text(
            trText('PRODUCT DETAILS'),
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              letterSpacing: 1.4,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 12),
          Text(
            trText(product.description),
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          if (product.problemKeywords.isNotEmpty) ...[
            SizedBox(height: 36),
            Text(
              trText('RECOMMENDED FOR'),
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1.4,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: product.problemKeywords.map((keyword) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    trText(keyword),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          SizedBox(height: 44),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _openAffiliateUrl(context),
              icon: Icon(LucideIcons.externalLink),
              label: Text(trText('View Product')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                minimumSize: Size.fromHeight(58),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
          SizedBox(height: 120),
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
            ? ColoredBox(
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
            return ColoredBox(
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
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.alertCircle, size: 44, color: AppTheme.onSurfaceVariant),
            SizedBox(height: 16),
            Text(
              trText('Unable to load this product.'),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: Text(trText('Try Again')),
            ),
          ],
        ),
      ),
    );
  }
}