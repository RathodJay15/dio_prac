import 'package:dio/dio.dart';
import 'users_service.dart';

class UsersController {
  final UsersService _service = UsersService();

  final int _limit = 20;
  int _skip = 0;
  bool _hasMore = true;
  bool _isLoading = false;

  final List<dynamic> users = [];

  CancelToken? _cancelToken;

  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;

  Future<String?> fetchUsers({bool refresh = false}) async {
    if (_isLoading) return null;

    if (refresh) {
      _skip = 0;
      _hasMore = true;
      users.clear();
    }

    if (!_hasMore) return null;

    _isLoading = true;
    _cancelToken = CancelToken();

    try {
      final response = await _service.fetchUsers(
        limit: _limit,
        skip: _skip,
        cancelToken: _cancelToken,
      );

      final List data = response.data['users'];

      users.addAll(data);
      _skip += _limit;

      if (data.length < _limit) {
        _hasMore = false;
      }

      _isLoading = false;
      return null;
    } on DioException catch (e) {
      _isLoading = false;

      if (CancelToken.isCancel(e)) {
        return null; // silent cancel
      }

      return 'Failed to load users';
    }
  }

  void cancelRequest() {
    _cancelToken?.cancel();
  }
}
