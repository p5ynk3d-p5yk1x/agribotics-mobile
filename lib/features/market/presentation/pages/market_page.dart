import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/marketplace_models.dart';
import '../../data/marketplace_providers.dart';

class MarketPage extends ConsumerStatefulWidget {
  const MarketPage({super.key});

  @override
  ConsumerState<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends ConsumerState<MarketPage> {
  final TextEditingController _searchController = TextEditingController();
  MarketplaceCategory? _selectedCategory;
  String _problem = '';
  int _page = 1;
  static const int _limit = 20;

  MarketplaceQuery get _query => (
  category: _selectedCategory,
  problem: _problem,
  page: _page,
  limit: _limit,
  );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectCategory(MarketplaceCategory? category) {
    setState(() {
      _selectedCategory = category;
      _problem = '';
      _searchController.clear();
      _page = 1;
    });
  }

  void _search(String value) {
    final query = value.trim();
    setState(() {
      _problem = query;
      _selectedCategory = null;
      _page = 1;
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _problem = '';
      _page = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(marketplaceProductsProvider(_query));
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(marketplaceProductsProvider(_query).future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.horizontalSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              Text('CURATED INPUTS', style: Theme.of(context).textTheme.labelLarge).animate().fadeIn().moveX(begin: -20, end: 0),
              const SizedBox(height: 8),
              Text('Marketplace', style: Theme.of(context).textTheme.displayLarge).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 24),
              const Text(
                'Agricultural inputs, machinery and crop protection products selected for modern estate management.',
                style: TextStyle(fontSize: 16, color: AppTheme.onSurfaceVariant, height: 1.5),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 36),
              _SearchField(
                controller: _searchController,
                onSubmitted: _search,
                onClear: _clearSearch,
              ),
              const SizedBox(height: 32),
              _CategoryFilter(
                selectedCategory: _selectedCategory,
                onSelected: _selectCategory,
              ),
              const SizedBox(height: 32),
              products.when(
                loading: () => const _LoadingGrid(),
                error: (error, _) => _ErrorState(
                  onRetry: () => ref.invalidate(marketplaceProductsProvider(_query)),
                ),
                data: (data) => Column(
                  children: [
                    _ProductGrid(products: data.items),
                    if (data.items.isNotEmpty) ...[
                      const SizedBox(height: 36),
                      _PaginationControls(
                        currentPage: data.pagination.page,
                        totalPages: data.pagination.totalPages,
                        onPrevious: data.pagination.page > 1 ? () => setState(() => _page--) : null,
                        onNext: data.pagination.page < data.pagination.totalPages ? () => setState(() => _page++) : null,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  const _SearchField({
    required this.controller,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: 'Search by crop problem...',
        prefixIcon: const Icon(LucideIcons.search),
        suffixIcon: IconButton(
          onPressed: onClear,
          icon: const Icon(LucideIcons.x),
        ),
        filled: true,
        fillColor: AppTheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }
}

class _CategoryFilter extends StatelessWidget {
  final MarketplaceCategory? selectedCategory;
  final ValueChanged<MarketplaceCategory?> onSelected;
  const _CategoryFilter({
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _CatChip(
            label: 'All Inputs',
            isActive: selectedCategory == null,
            onTap: () => onSelected(null),
          ),
          ...MarketplaceCategory.values.map((category) {
            return _CatChip(
              label: category.label,
              isActive: selectedCategory == category,
              onTap: () => onSelected(category),
            );
          }),
        ],
      ),
    );
  }
}

class _CatChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _CatChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
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
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  final List<MarketplaceProduct> products;
  const _ProductGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Center(
          child: Column(
            children: [
              Icon(LucideIcons.packageSearch, size: 44, color: AppTheme.onSurfaceVariant),
              SizedBox(height: 16),
              Text(
                'No products found.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 18,
        crossAxisSpacing: 18,
        childAspectRatio: 0.66,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _ProductCard(product: product)
            .animate()
            .fadeIn(delay: (100 + (index * 40)).ms)
            .moveY(begin: 15, end: 0);
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final MarketplaceProduct product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/market/product/${product.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: _ProductImage(imageUrl: product.imageUrl),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.category != null) ...[
                    Text(
                      product.category!.label.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.formattedPrice,
                    style: const TextStyle(
                      color: AppTheme.secondary,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String? imageUrl;
  const _ProductImage({this.imageUrl});

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

    if (formattedUrl == null) {
      return const ColoredBox(
        color: AppTheme.background,
        child: Center(
          child: Icon(
            LucideIcons.image,
            size: 36,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Image.network(
      formattedUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return const ColoredBox(
          color: AppTheme.background,
          child: Center(
            child: Icon(
              LucideIcons.imageOff,
              size: 36,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }
}

class _PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  const _PaginationControls({
    required this.currentPage,
    required this.totalPages,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(LucideIcons.chevronLeft),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '$currentPage / ${totalPages == 0 ? 1 : totalPages}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(LucideIcons.chevronRight),
        ),
      ],
    );
  }
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Center(
        child: Column(
          children: [
            const Icon(LucideIcons.wifiOff, size: 42, color: AppTheme.onSurfaceVariant),
            const SizedBox(height: 16),
            const Text(
              'Unable to load marketplace.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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