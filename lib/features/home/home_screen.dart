import 'package:dio_prac/features/auth/login_screen.dart';
import 'package:flutter/material.dart';
import '../products/add_product_screen.dart';
import '../users/users_screen.dart';
import '../../core/models/user_model.dart';
import '../../core/storage/token_storage.dart';
import '../../features/products/products_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  UserModel? _user;
  int _currentIndex = 1;

  // Dummy user data (replace with SharedPrefs / SecureStorage)
  final String username = 'emilys';
  final String email = 'emily.johnson@dummyjson.com';

  final List<Widget> _screens = const [
    UsersScreen(),
    ProductsScreen(),
    AddProductScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _logout() {
    TokenStorage.clearToken();
    TokenStorage.clearUser();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _loadUser() async {
    final user = await TokenStorage.getUser();
    setState(() => _user = user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.orangeAccent.withValues(alpha: 0.20),
        title: const Text('Our Products'),
        actions: [
          IconButton(onPressed: () => _logout(), icon: Icon(Icons.logout)),
        ],
      ),

      drawer: Drawer(
        child: Column(
          children: [
            if (_user != null)
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Colors
                      .orangeAccent, // Or use Colors.red, Color(0xFF....), etc.
                ),
                accountName: Text(
                  '${_user!.firstName} ${_user!.lastName} || ${_user!.username}',
                ),
                accountEmail: Text(_user!.email),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(_user!.image),
                ),
              ),

            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Users'),
              onTap: () => setState(() {
                Navigator.pop(context);
                _currentIndex = 0;
              }),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text('Products'),
              onTap: () => setState(() {
                Navigator.pop(context);
                _currentIndex = 1;
              }),
            ),
            ListTile(
              leading: const Icon(Icons.note_add_outlined),
              title: const Text('Add PRoduct'),
              onTap: () => setState(() {
                Navigator.pop(context);
                _currentIndex = 2;
              }),
            ),

            Divider(height: 2, color: Colors.orangeAccent),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _logout(),
            ),
          ],
        ),
      ),

      //  IndexedStack
      body: IndexedStack(index: _currentIndex, children: _screens),

      //  Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.orange,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_add_outlined),
            label: 'Add Product',
          ),
        ],
      ),
    );
  }
}
