import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import 'marketplace_api.dart';
import 'marketplace_models.dart';

final marketplaceApiProvider = Provider<MarketplaceApi>((ref) {
  return MarketplaceApi(ref.watch(dioProvider));
});

typedef MarketplaceQuery = ({
MarketplaceCategory? category,
String problem,
int page,
int limit,
});

final marketplaceProductsProvider = FutureProvider.family<MarketplaceProductPage, MarketplaceQuery>((ref, query) async {
  final api = ref.watch(marketplaceApiProvider);
  final problem = query.problem.trim();
  if (problem.isNotEmpty) {
    return api.getProductsByProblem(problem, page: query.page, limit: query.limit);
  }
  if (query.category != null) {
    return api.getProductsByCategory(query.category!, page: query.page, limit: query.limit);
  }
  return api.getProducts(page: query.page, limit: query.limit);
});

final marketplaceProductProvider = FutureProvider.family<MarketplaceProduct, String>((ref, id) {
  return ref.watch(marketplaceApiProvider).getProduct(id);
});