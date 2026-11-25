import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/products_screen.dart';
import 'screens/product_detail_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/face_scan_screen.dart';
import 'screens/virtual_makeup_screen.dart';
import 'screens/signup_screen.dart';
import 'models/app_state.dart';
import 'package:path/path.dart' as p;

import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MakeupApp());
}

class MakeupApp extends StatelessWidget {
  const MakeupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AppWithTheme();
  }
}

class _AppWithTheme extends StatefulWidget {
  const _AppWithTheme({super.key});

  @override
  State<_AppWithTheme> createState() => _AppWithThemeState();
}

class _AppWithThemeState extends State<_AppWithTheme> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _isDarkMode = prefs.getBool('darkMode') ?? false);
  }

  Future<void> _toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    setState(() => _isDarkMode = value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LuceBella - 3D Makyaj Uygulaması',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: AppNavigator(
        isDarkMode: _isDarkMode,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class AppNavigator extends StatefulWidget {
  final bool isDarkMode;
  final Future<void> Function(bool) onToggleTheme;

  const AppNavigator({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  final AppState _appState = AppState();
  String _currentScreen = 'home';

  void _navigateTo(String screen, {dynamic data}) {
    setState(() {
      _currentScreen = screen;
      if (data != null && screen == 'productdetail') {
        _appState.selectedProduct = data;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentScreen) {
      case 'login':
        return LoginScreen(
          onNavigate: _navigateTo,
          onLogin: (user) {
            _appState.user = user;
            _navigateTo('home');
          },
        );
      case 'signup':
        return SignUpScreen(
          onNavigate: _navigateTo,
          onSignUp: (user) {
            _appState.user = null;
            _navigateTo('login');
          },
        );
      case 'home':
        return HomeScreen(
          user: _appState.user,
          onNavigate: _navigateTo,
        );
      case 'products':
        return ProductsScreen(
          onNavigate: _navigateTo,
          likedProducts: _appState.likedProducts,
          onToggleLike: (product) {
            _appState.toggleLike(product);
            setState(() {});
          },
        );
      case 'productdetail':
        return ProductDetailScreen(
          product: _appState.selectedProduct,
          onNavigate: _navigateTo,
          onAddToCart: (product) {
            _appState.addToCart(product);
            setState(() {});
          },
          onToggleLike: (product) => _appState.toggleLike(product),
          likedProducts: _appState.likedProducts,
        );
      case 'cart':
        return CartScreen(
          items: _appState.cartItems,
          onNavigate: _navigateTo,
          onRemoveItem: (index) {
            _appState.removeFromCart(index);
            setState(() {});
          },
        );
      case 'profile':
        return ProfileScreen(
          user: _appState.user,
          onNavigate: _navigateTo,
          onUpdateUser: (user) {
            _appState.user = user;
            setState(() {});
          },
          likedProducts: _appState.likedProducts,
          onToggleLike: (product) {
            _appState.toggleLike(product);
            setState(() {});
          },
        );
      case 'settings':
        return SettingsScreen(
          user: _appState.user,
          onNavigate: _navigateTo,
          onLogout: () {
            _appState.user = null;
            _navigateTo('login');
          },
          isDarkMode: widget.isDarkMode,
          onToggleTheme: widget.onToggleTheme,
        );
      case 'facescan':
        return FaceScanScreen(
          onNavigate: _navigateTo,
          onScanComplete: (model) {
            _appState.scannedModel = model;
            setState(() {});
          },
        );
      case 'virtualmakeup':
        return VirtualMakeupScreen(
          onNavigate: _navigateTo,
          scannedModel: _appState.scannedModel,
        );
      default:
        return LoginScreen(
          onNavigate: _navigateTo,
          onLogin: (user) {
            _appState.user = user;
            _navigateTo('home');
          },
        );
    }
  }
}