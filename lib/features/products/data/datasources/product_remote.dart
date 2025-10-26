import 'package:products_pagination_caching_secure_token/core/api/dio_client.dart';
import 'package:products_pagination_caching_secure_token/core/cache/hive_manager.dart';

import '../models/product_model.dart';

class ProductRemote {
  final DioClient dioClient = DioClient();

  Future<List<ProductModel>> getProducts({int page = 1, int limit = 10}) async {
    final cacheKey = 'products_page_$page';
    try {
      final response = await dioClient.dio.get(
        '/products',
        queryParameters: {'page': page, 'limit': limit},
      );

      // Convert each product JSON → ProductModel
      final List<ProductModel> products = (response.data as List)
          .map((item) => ProductModel.fromJson(item))
          .toList();

      // Save list of maps (for Hive caching)
      await HiveManager.save(
        cacheKey,
        products.map((p) => p.toJson()).toList(),
      );

      return products;
    } catch (e) {
      // If offline, load cached list
      final cached = HiveManager.get(cacheKey);
      if (cached != null) {
        return (cached as List)
            .map(
              (item) => ProductModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      }
      rethrow;
    }
  }
}
