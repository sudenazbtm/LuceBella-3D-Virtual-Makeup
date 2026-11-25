import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AppState {
  dynamic user;
  List<dynamic> cartItems = [];
  List<dynamic> likedProducts = [];
  dynamic selectedProduct;
  dynamic scannedModel;

  AppState() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) {
      user = jsonDecode(userStr);
    }
    final likedStr = prefs.getString('likedProducts');
    if (likedStr != null) {
      likedProducts = jsonDecode(likedStr);
    }
  }

  void addToCart(dynamic product) {
    cartItems.add(product);
  }

  void removeFromCart(int index) {
    if (index < cartItems.length) {
      cartItems.removeAt(index);
    }
  }

  bool toggleLike(dynamic product) {
    final index = likedProducts.indexWhere((p) => p['id'] == product['id']);
    if (index >= 0) {
      likedProducts.removeAt(index);
      _saveLikedProducts();
      return false;
    } else {
      likedProducts.add(product);
      _saveLikedProducts();
      return true;
    }
  }

  Future<void> _saveLikedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('likedProducts', jsonEncode(likedProducts));
  }
}
