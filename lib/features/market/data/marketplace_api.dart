import 'package:dio/dio.dart';
import 'marketplace_models.dart';

class MarketplaceApi {
  final Dio dio;
  const MarketplaceApi(this.dio);

  Future<MarketplaceProductPage> getProducts({int page = 1, int limit = 20}) async {
    final response = await dio.get('/api/marketplace/products', queryParameters: {
      'page': page,
      'limit': limit,
    });
    return MarketplaceProductPage.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<MarketplaceProductPage> getProductsByCategory(MarketplaceCategory category, {int page = 1, int limit = 20}) async {
    final response = await dio.get('/api/marketplace/products/category/${category.value}', queryParameters: {
      'page': page,
      'limit': limit,
    });
    return MarketplaceProductPage.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<MarketplaceProductPage> getProductsByProblem(String problem, {int page = 1, int limit = 20}) async {
    final response = await dio.get('/api/marketplace/products/problem/$problem', queryParameters: {
      'page': page,
      'limit': limit,
    });
    return MarketplaceProductPage.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  Future<MarketplaceProduct> getProduct(String id) async {
    final response = await dio.get('/api/marketplace/products/$id');
    return MarketplaceProduct.fromJson(Map<String, dynamic>.from(response.data as Map));
  }
}