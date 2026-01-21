import 'package:dio/dio.dart';
import 'products_service.dart';

class ProductsController {
  final ProductsService _service = ProductsService();

  final int _limit = 10;
  int _skip = 0;
  bool _hasMore = true;
  bool _isLoading = false;

  String _currentSearch = '';

  final List<dynamic> products = [];
  CancelToken? _cancelToken;

  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;

  String? _selectedCategory;
  List<String> categories = [];

  String? selectedCategory;

  void setCategory(String? category) {
    selectedCategory = category;
  }

  Future<void> applyFilters() async {
    await fetchProducts(refresh: true, category: selectedCategory);
  }

  Future<void> loadCategories() async {
    categories = await _service.fetchCategories();
  }

  Future<String?> fetchProducts({
    bool refresh = false,
    String search = '',
    String? category,
  }) async {
    if (isLoading) return null;
    if (!hasMore && !refresh) return null;
    _isLoading = true;

    //  Cancel previous request (important)
    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    if (refresh || search != _currentSearch || category != _selectedCategory) {
      _skip = 0;
      _hasMore = true;
      products.clear();
    }

    _currentSearch = search;
    _selectedCategory = category;

    try {
      late Response response;
      if (category != null && category.isNotEmpty) {
        response = await _service.fetchProductsByCategory(
          category: category,
          limit: _limit,
          skip: _skip,
          cancelToken: _cancelToken,
        );
      } else {
        response = await _service.fetchProducts(
          limit: _limit,
          skip: _skip,
          search: search,
          cancelToken: _cancelToken,
        );
      }

      final List data = response.data['products'];

      products.addAll(data);
      _skip += _limit;

      if (data.length < _limit) {
        _hasMore = false;
      }

      _isLoading = false;
      return null;
    } on DioException catch (e) {
      _isLoading = false;

      if (CancelToken.isCancel(e)) {
        return null; //  silent cancel
      }

      return 'Failed to load products';
    }
  }

  void cancelRequest() {
    _cancelToken?.cancel();
  }
}
