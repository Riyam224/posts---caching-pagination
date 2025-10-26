import 'package:flutter/material.dart';
import 'package:products_pagination_caching_secure_token/features/products/data/datasources/product_remote.dart';
import 'package:products_pagination_caching_secure_token/features/products/data/models/product_model.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';


class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final _controller = RefreshController();
  final _remote = ProductRemote();

  final List<ProductModel> _products = [];
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  /// Fetch products from API or cache
  Future<void> _loadProducts({bool refresh = false}) async {
    if (_loading) return; // prevent duplicate calls
    setState(() => _loading = true);

    if (refresh) {
      _page = 1;
      _products.clear();
      _hasMore = true;
    }

    try {
      final data = await _remote.getProducts(page: _page, limit: 10);

      setState(() {
        if (data.isEmpty) {
          _hasMore = false;
        } else {
          _products.addAll(data);
          _page++;
        }
      });
    } catch (e) {
      debugPrint("Error loading products: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Offline mode: showing cached data")),
      );
    } finally {
      setState(() => _loading = false);
      _controller.refreshCompleted();
      _controller.loadComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(title: const Text('Products'), centerTitle: true),
      body: SmartRefresher(
        controller: _controller,
        enablePullUp: _hasMore,
        onRefresh: () => _loadProducts(refresh: true),
        onLoading: _hasMore ? _loadProducts : null,
        child: _products.isEmpty && !_loading
            ? const Center(child: Text("No products available"))
            : ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final p = _products[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          p.image,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image),
                        ),
                      ),
                      title: Text(
                        p.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        "\$${p.price.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
