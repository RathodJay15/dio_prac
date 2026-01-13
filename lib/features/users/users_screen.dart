import 'package:flutter/material.dart';
import 'users_controller.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final UsersController _controller = UsersController();
  final ScrollController _scrollController = ScrollController();

  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInitial();

    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadInitial() async {
    final error = await _controller.fetchUsers();
    setState(() => _error = error);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _controller.fetchUsers().then((error) {
        if (error != null) {
          setState(() => _error = error);
        } else {
          setState(() {});
        }
      });
    }
  }

  Future<void> _refresh() async {
    final error = await _controller.fetchUsers(refresh: true);
    setState(() => _error = error);
  }

  @override
  void dispose() {
    _controller.cancelRequest();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //  Initial loading
    if (_controller.users.isEmpty && _controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    //  Error state
    if (_error != null && _controller.users.isEmpty) {
      return Center(child: Text(_error!));
    }

    //  Data state → ONLY here use RefreshIndicator
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _controller.users.length + (_controller.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _controller.users.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final user = _controller.users[index];

          return ListTile(
            title: Text('${user['firstName']} ${user['lastName']}'),
            subtitle: Text(user['email']),
          );
        },
      ),
    );
  }
}
