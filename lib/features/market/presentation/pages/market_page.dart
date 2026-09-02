import 'package:agribotics/core/localization/localized_text.dart';
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
  static int _limit = 20;

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
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: AppTheme.horizontalSpacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 80),
              Text(trText('CURATED INPUTS'), style: Theme.of(context).textTheme.labelLarge).animate().fadeIn().moveX(begin: -20, end: 0),
              SizedBox(height: 8),
              Text(trText('Marketplace'), style: Theme.of(context).textTheme.displayLarge).animate().fadeIn(delay: 200.ms),
              SizedBox(height: 24),
              Text(
                trText('Agricultural inputs, machinery and crop protection products selected for modern estate management.'),
                style: TextStyle(fontSize: 16, color: AppTheme.onSurfaceVariant, height: 1.5),
              ).animate().fadeIn(delay: 400.ms),
              SizedBox(height: 36),
              _SearchField(
                controller: _searchController,
                onSubmitted: _search,
                onClear: _clearSearch,
              ),
              SizedBox(height: 32),
              _CategoryFilter(
                selectedCategory: _selectedCategory,
                onSelected: _selectCategory,
              ),
              SizedBox(height: 32),
              products.when(
                loading: () => _LoadingGrid(),
                error: (error, _) => _ErrorState(
                  onRetry: () => ref.invalidate(marketplaceProductsProvider(_query)),
                ),
                data: (data) => Column(
                  children: [
                    _ProductGrid(products: data.items),
                    if (data.items.isNotEmpty) ...[
                      SizedBox(height: 36),
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
              SizedBox(height: 120),
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
        prefixIcon: Icon(LucideIcons.search),
        suffixIcon: IconButton(
          onPressed: onClear,
          icon: Icon(LucideIcons.x),
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
          borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
        duration: Duration(milliseconds: 200),
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : AppTheme.surface,
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
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 80),
        child: Center(
          child: Column(
            children: [
              Icon(LucideIcons.packageSearch, size: 44, color: AppTheme.onSurfaceVariant),
              SizedBox(height: 16),
              Text(
                trText('No products found.'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.category != null) ...[
                    Text(
                      trText(product.category!.label.toUpperCase()),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: 6),
                  ],
                  Text(
                    trText(product.name),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    trText(product.formattedPrice),
                    style: TextStyle(
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
      return ColoredBox(
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
        return ColoredBox(
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
          icon: Icon(LucideIcons.chevronLeft),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            trText('$currentPage / ${totalPages == 0 ? 1 : totalPages}'),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: Icon(LucideIcons.chevronRight),
        ),
      ],
    );
  }
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
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
      padding: EdgeInsets.symmetric(vertical: 64),
      child: Center(
        child: Column(
          children: [
            Icon(LucideIcons.wifiOff, size: 42, color: AppTheme.onSurfaceVariant),
            SizedBox(height: 16),
            Text(
              trText('Unable to load marketplace.'),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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