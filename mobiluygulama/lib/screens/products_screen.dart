import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/logo.dart';
import '../data/products_data.dart';

class ProductsScreen extends StatefulWidget {
  final Function(String, {dynamic data}) onNavigate;
  final List<dynamic> likedProducts;
  final Function(dynamic) onToggleLike;

  const ProductsScreen({
    super.key,
    required this.onNavigate,
    required this.likedProducts,
    required this.onToggleLike,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _selectedCategory = 'all';
  String _searchQuery = '';
  String _sortBy = 'popular';
  bool _showFilters = false;
  String _priceRange = 'all';
  String _selectedPlatform = 'all';

  
  final _categories = [
    {'id': 'all', 'name': 'Tümü', 'icon': '✨'},
    {'id': 'ruj', 'name': 'Ruj', 'icon': '💄'},
    {'id': 'fondöten', 'name': 'Fondöten', 'icon': '🧴'},
    {'id': 'allık', 'name': 'Allık', 'icon': '🌸'},
    {'id': 'far', 'name': 'Far', 'icon': '👁️'},
    {'id': 'eyeliner', 'name': 'Eyeliner', 'icon': '✏️'},
    {'id': 'maskara', 'name': 'Maskara', 'icon': '👀'},
    {'id': 'kapatıcı', 'name': 'Kapatıcı', 'icon': '⭐'},
    {'id': 'aydınlatıcı', 'name': 'Aydınlatıcı', 'icon': '✨'},
    {'id': 'kontür', 'name': 'Kontür', 'icon': '🎨'},
    {'id': 'bronzer', 'name': 'Bronzer', 'icon': '☀️'},
  ];

  final _sortOptions = [
    {'id': 'popular', 'name': 'En Popüler'},
    {'id': 'rating', 'name': 'En Yüksek Puan'},
    {'id': 'price-low', 'name': 'Fiyat: Düşükten Yükseğe'},
    {'id': 'price-high', 'name': 'Fiyat: Yüksekten Düşüğe'},
    {'id': 'newest', 'name': 'En Yeni'},
  ];

  final _priceRanges = [
    {'id': 'all', 'name': 'Tüm Fiyatlar'},
    {'id': '0-200', 'name': '₺0 - ₺200'},
    {'id': '200-500', 'name': '₺200 - ₺500'},
    {'id': '500-1000', 'name': '₺500 - ₺1.000'},
    {'id': '1000+', 'name': '₺1.000+'},
  ];

  final _platforms = [
    {'id': 'all', 'name': 'Tüm Markalar'},
    {'id': 'LuceBella', 'name': 'LuceBella'},
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    var products = List<Map<String, dynamic>>.from(allProducts);
    
    
    if (_selectedCategory != 'all') {
      products = products.where((p) => p['category'] == _selectedCategory).toList();
    }

    
    products = products.where((p) {
      final price = (p['price'] as num).toDouble();
      switch (_priceRange) {
        case '0-200':
          return price <= 200;
        case '200-500':
          return price > 200 && price <= 500;
        case '500-1000':
          return price > 500 && price <= 1000;
        case '1000+':
          return price > 1000;
        default:
          return true;
      }
    }).toList();

    
    if (_selectedPlatform != 'all') {
      products = products.where((p) => p['brand'] == _selectedPlatform).toList();
    }
    
    
    if (_searchQuery.isNotEmpty) {
      products = products.where((p) {
        return p['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
               p['brand'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
               p['colorCode'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    
    if (_sortBy == 'popular') {
      products.sort((a, b) => (b['reviews'] as int).compareTo(a['reviews'] as int));
    } else if (_sortBy == 'rating') {
      products.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
    } else if (_sortBy == 'price-low') {
      products.sort((a, b) => (a['price'] as double).compareTo(b['price'] as double));
    } else if (_sortBy == 'price-high') {
      products.sort((a, b) => (b['price'] as double).compareTo(a['price'] as double));
    } else if (_sortBy == 'newest') {
      products.sort((a, b) => ((b['isNew'] == true ? 1 : 0)).compareTo((a['isNew'] == true ? 1 : 0)));
    }
    
    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          
          Container(
            color: Colors.black,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Logo(variant: 'light', size: 'md', onClick: () => widget.onNavigate('home')),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => widget.onNavigate('cart'),
                              icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                              tooltip: 'Sepet',
                              style: IconButton.styleFrom(
                                hoverColor: Colors.white.withOpacity(0.1),
                                padding: const EdgeInsets.all(8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: TextField(
                      onChanged: (value) => setState(() => _searchQuery = value),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        hintText: 'Ürün ara...',
                        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
                        filled: true,
                        fillColor: const Color(0xFF1F1F1F),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  
                  Container(
                    height: 80,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final cat = _categories[index];
                        final isSelected = _selectedCategory == cat['id'];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat['id'] as String),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.black : Colors.grey[100],
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                Text(cat['icon'] as String, style: const TextStyle(fontSize: 14)),
                                const SizedBox(width: 6),
                                Text(
                                  cat['name'] as String,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.grey[700],
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            
                            InkWell(
                              onTap: () => setState(() => _showFilters = !_showFilters),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.tune, size: 16, color: Colors.black),
                                    const SizedBox(width: 8),
                                    Text(
                                      _showFilters ? 'Filtreleri Gizle' : 'Filtreler',
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _sortBy,
                                    icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.black),
                                    isExpanded: true,
                                    style: const TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w500),
                                    items: _sortOptions.map((option) {
                                      return DropdownMenuItem(
                                        value: option['id'],
                                        child: Text(option['name']!),
                                      );
                                    }).toList(),
                                    onChanged: (value) => setState(() => _sortBy = value!),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        
                        if (_showFilters) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('FİYAT ARALIĞI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _priceRanges.map((range) {
                                    final isSelected = _priceRange == range['id'];
                                    return GestureDetector(
                                      onTap: () => setState(() => _priceRange = range['id']!),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.black : Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: isSelected ? null : Border.all(color: Colors.grey[300]!),
                                        ),
                                        child: Text(
                                          range['name']!,
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.grey[700],
                                            fontSize: 12,
                                            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 16),
                                const Text('MARKA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _platforms.map((platform) {
                                    final isSelected = _selectedPlatform == platform['id'];
                                    return GestureDetector(
                                      onTap: () => setState(() => _selectedPlatform = platform['id']!),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.black : Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: isSelected ? null : Border.all(color: Colors.grey[300]!),
                                        ),
                                        child: Text(
                                          platform['name']!,
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.grey[700],
                                            fontSize: 12,
                                            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _filteredProducts.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Column(
                                children: [
                                  Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Ürün bulunamadı',
                                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                                  ),
                                  const SizedBox(height: 12),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _searchQuery = '';
                                        _selectedCategory = 'all';
                                        _priceRange = 'all';
                                        _selectedPlatform = 'all';
                                      });
                                    },
                                    child: const Text('Filtreleri Temizle', style: TextStyle(color: Colors.black)),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final isDesktop = constraints.maxWidth > 600;
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isDesktop ? 4 : 2,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: isDesktop ? 0.6 : 0.50,
                                ),
                                itemCount: _filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final product = _filteredProducts[index];
                                  final isLiked = widget.likedProducts.any((p) => p['id'] == product['id']);
                                  return _ProductCard(
                                    product: product,
                                    isLiked: isLiked,
                                    onTap: () => widget.onNavigate('productdetail', data: product),
                                    onLike: () => widget.onToggleLike(product),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 100), 
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentScreen: 'products',
        onNavigate: widget.onNavigate,
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isLiked;
  final VoidCallback onTap;
  final VoidCallback onLike;

  const _ProductCard({
    required this.product,
    required this.isLiked,
    required this.onTap,
    required this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: CachedNetworkImage(
                          imageUrl: product['image'],
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(color: Colors.grey[200]),
                        ),
                      ),
                      if (product['isNew'] == true)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'YENİ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _parseColor(product['color']),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LUCEBELLA',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 9,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        height: 34,
                        child: Text(
                          product['name'].toString().replaceAll('LuceBella ', ''),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.star, size: 12, color: Colors.amber[400]),
                          const SizedBox(width: 3),
                          Text(
                            '${product['rating']}',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[700]),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            ' (${product['reviews']})',
                            style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(right: 32),
                        child: Text(
                          product['priceText'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Positioned(
              bottom: 10,
              right: 10,
              child: GestureDetector(
                onTap: onLike,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 14,
                    color: isLiked ? Colors.red : Colors.grey[400],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.grey;
    }
  }
}