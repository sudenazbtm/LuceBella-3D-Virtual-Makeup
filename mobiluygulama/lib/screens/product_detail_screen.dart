import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? product;
  final Function(String, {dynamic data}) onNavigate;
  final Function(dynamic) onAddToCart;
  final Function(dynamic) onToggleLike;
  final List<dynamic> likedProducts;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.onNavigate,
    required this.onAddToCart,
    required this.onToggleLike,
    required this.likedProducts,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _added = false;
  String _activeTab = 'info';

  final List<String> _skinTypes = ['Normal', 'Kuru', 'Karma', 'Yağlı'];

  final Map<String, List<String>> _compatibleSkinTypes = {
    'fondöten': ['Normal', 'Kuru', 'Karma'],
    'kapatıcı': ['Normal', 'Kuru', 'Karma'],
  };

  final Map<String, List<String>> _usageInstructions = {
    'ruj': [
      'Dudak peelingi ile ölü derileri temizleyin ve nemlendirin',
      'Dudak kalemiyle hatları belirleyin',
      'Rujunuzu ortadan başlayarak kenarlara sürün',
      'Kalıcılık için ikinci kat ve şeffaf pudra uygulayın',
    ],
    'fondöten': [
      'Cildi temizleyip nemlendirin, baz uygulayın',
      'Alın ortasından dışa doğru yayın',
      'Boyun ve çeneyi unutmadan süngerle blendleyin',
      'Mat görünüm için pudra ile sabitleyin',
    ],
    'allık': [
      'Gülümseyip elmacık kemiklerine dairesel hareketlerle uygulayın',
      'Şakaklara doğru hafifçe dağıtın',
      'Doğal görünüm için iyice blendleyin',
    ],
    'far': [
      'Baz uygulayın, açık tonu tüm kapağa sürün',
      'Orta tonu hareketli kapağa, koyu tonu crease bölgesine ekleyin',
      'Tonları birbirine yedirin, iç köşeyi aydınlatın',
    ],
    'eyeliner': [
      'Göz kuyruğundan başlayın',
      'Kirpik diplerini doldurup içe doğru ince çizgi çekin',
      'Dış köşede kuyruk verin, hataları kapatıcıyla düzeltin',
    ],
    'maskara': [
      'Kirpikleri kıvırın, zigzag hareketiyle dipten uca uygulayın',
      'Alt kirpiklere fırçanın ucuyla dokundurun',
      'İkinci kat için kurumasını bekleyin',
    ],
    'kapatıcı': [
      'Göz altına ters üçgen, lekelere noktasal uygulayın',
      'Nemli süngerle bastırarak yaydırın',
      'Şeffaf pudra ile sabitleyin',
    ],
    'aydınlatıcı': [
      'Elmacık üstüne “C” hareketi, burun köprüsü ve dudak üzeri',
      'İç köşe ve kaş altına hafifçe uygulayın',
    ],
    'kontür': [
      'Elmacık altına, saç çizgisine ve çene hattına ince şerit çekin',
      'Yumuşak fırça ile dağıtın, aydınlatıcıyla vurgulayın',
    ],
    'bronzer': [
      'Saç çizgisinden elmacık altına “3” şeklinde sürün',
      'Boyunla yüz rengini eşitleyin, doğal görünüm için blendleyin',
    ],
  };

  final Map<String, String> _ingredients = {
    'ruj':
        'Ricinus Communis Seed Oil, Ozokerite, Silica, Tocopheryl Acetate, Parfum',
    'fondöten':
        'Cyclopentasiloxane, Water, Titanium Dioxide, Dimethicone, Sodium Hyaluronate',
    'allık':
        'Talc, Mica, Magnesium Stearate, Dimethicone, Tocopheryl Acetate, Iron Oxides',
    'far':
        'Mica, Talc, Dimethicone, Zinc Stearate, Caprylyl Glycol, Titanium Dioxide, Iron Oxides',
    'eyeliner':
        'Aqua, Styrene/Acrylates Copolymer, PVP, Phenoxyethanol, Black 2',
    'maskara':
        'Aqua, Cera Carnauba, Glyceryl Stearate, Stearic Acid, Panthenol, Iron Oxides',
    'kapatıcı':
        'Cyclopentasiloxane, Aqua, Dimethicone, Titanium Dioxide, Glycerin, Nylon-12',
    'aydınlatıcı':
        'Mica, Synthetic Fluorphlogopite, Dimethicone, Octyldodecyl Stearoyl Stearate',
    'kontür':
        'Talc, Mica, Magnesium Stearate, Dimethicone, Caprylic/Capric Triglyceride',
    'bronzer':
        'Mica, Talc, Dimethicone, Magnesium Stearate, Ethylhexyl Palmitate',
  };

  final List<Map<String, dynamic>> _userReviews = [
    {
      'user': 'Ayşe K.',
      'rating': 5,
      'date': '2 gün önce',
      'comment':
          'Harika bir ürün! Rengi tam beklediğim gibiydi. Kalıcılığı çok iyi, tüm gün boyunca hiç solmadı.',
      'helpful': 127,
      'verified': true,
    },
    {
      'user': 'Zeynep M.',
      'rating': 4,
      'date': '1 hafta önce',
      'comment':
          'Ürün gerçekten kaliteli ancak fiyatı biraz yüksek. Yine de parasını hak ediyor.',
      'helpful': 89,
      'verified': true,
    },
    {
      'user': 'Elif Y.',
      'rating': 5,
      'date': '2 hafta önce',
      'comment':
          'En sevdiğim ürün oldu! Cildime çok yakıştı, ton mükemmel. Herkese tavsiye ediyorum.',
      'helpful': 156,
      'verified': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.product == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Ürün bulunamadı'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => widget.onNavigate('products'),
                child: const Text('Ürünlere Dön'),
              ),
            ],
          ),
        ),
      );
    }

    final product = widget.product!;
    final isLiked = widget.likedProducts.any((p) => p['id'] == product['id']);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => widget.onNavigate('products'),
                  ),
                  const Expanded(
                    child: Text(
                      'Ürün Detayı',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.white,
                    ),
                    onPressed: () => widget.onToggleLike(product),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    SizedBox(
                      height: 350, 
                      width: double.infinity,
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: product['image'],
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          
                          Positioned(
                            top: 16,
                            right: 16,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (product['isNew'] == true) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'YENİ ÜRÜN',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                Container(
                                  width: 40, 
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _parseColor(product['color']),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    product['colorCode'],
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Padding(
                      padding: const EdgeInsets.all(20), 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          
                          
                          Text(
                            product['name'],
                            style: const TextStyle(
                              fontSize: 22, 
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ...List.generate(5, (index) {
                                return Icon(
                                  Icons.star,
                                  size: 16,
                                  color: index < (product['rating'] as double).floor()
                                      ? Colors.amber
                                      : Colors.grey[300],
                                );
                              }),
                              const SizedBox(width: 8),
                              Text(
                                '${product['rating']}',
                                style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '•',
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${product['reviews']} değerlendirme',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.only(bottom: 16),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['priceText'],
                                      style: const TextStyle(
                                        fontSize: 26, 
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'KDV Dahil • Ücretsiz Kargo',
                                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                                    ),
                                  ],
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                  child: Row(
                                    children: [
                                      _QuantityButton(
                                        icon: Icons.remove,
                                        onTap: () {
                                          setState(() {
                                            _quantity = (_quantity > 1) ? _quantity - 1 : 1;
                                          });
                                        },
                                      ),
                                      SizedBox(
                                        width: 32,
                                        child: Text(
                                          '$_quantity',
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      _QuantityButton(
                                        icon: Icons.add,
                                        onTap: () {
                                          setState(() {
                                            _quantity++;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          Row(
                            children: [
                              _TabButton(
                                label: 'Bilgiler',
                                isActive: _activeTab == 'info',
                                onTap: () => setState(() => _activeTab = 'info'),
                              ),
                              _TabButton(
                                label: 'Kullanım',
                                isActive: _activeTab == 'usage',
                                onTap: () => setState(() => _activeTab = 'usage'),
                              ),
                              _TabButton(
                                label: 'Yorumlar (${product['reviews']})',
                                isActive: _activeTab == 'reviews',
                                onTap: () => setState(() => _activeTab = 'reviews'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          if (_activeTab == 'info') _buildInfoTab(product),
                          if (_activeTab == 'usage') _buildUsageTab(product),
                          if (_activeTab == 'reviews') _buildReviewsTab(product),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80), 
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              widget.onAddToCart({...product, 'quantity': _quantity});
              setState(() {
                _added = true;
              });
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  setState(() {
                    _added = false;
                  });
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _added ? Colors.green[600] : Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_added) ...[
                  const Icon(Icons.check_circle, size: 20),
                  const SizedBox(width: 8),
                  const Text('Sepete Eklendi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ] else ...[
                  const Icon(Icons.shopping_cart, size: 20),
                  const SizedBox(width: 8),
                  Text('Sepete Ekle ($_quantity Adet)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ],
            ),
          ),
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

  Widget _buildInfoTab(Map<String, dynamic> product) {
    final type = product['category'] as String? ?? '';
    final compatible = _compatibleSkinTypes[type] ?? _skinTypes;
    final ingredients = _ingredients[type] ??
        'İçerik bilgisi yakında eklenecektir.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cilt Tipi Uyumluluğu',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600), 
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _skinTypes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 4.0, 
          ),
          itemBuilder: (context, index) {
            final skin = _skinTypes[index];
            final isCompatible = compatible.contains(skin);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isCompatible ? Colors.green[50] : Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isCompatible ? Icons.check_circle : Icons.info_outline,
                    size: 16,
                    color: isCompatible ? Colors.green[600] : Colors.grey[400],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    skin,
                    style: TextStyle(
                      color: isCompatible ? Colors.green[700] : Colors.grey[500],
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Text(
              'İçerik Listesi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Icon(Icons.info_outline, size: 16, color: Colors.grey[400]),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            ingredients,
            style: const TextStyle(color: Colors.black87, height: 1.4, fontSize: 13),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber[700], size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hassas cildiniz varsa kullanmadan önce yama testi yapmanızı öneririz.',
                  style: TextStyle(color: Colors.amber[900], fontSize: 12, height: 1.3),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _InfoPill(label: 'Satış Platformu', value: (product['platform'] ?? '').toString().toUpperCase()),
            const SizedBox(width: 8),
            _InfoPill(label: 'Renk Kodu', value: product['colorCode'] ?? ''),
          ],
        ),
      ],
    );
  }

  Widget _buildUsageTab(Map<String, dynamic> product) {
    final steps = _usageInstructions[product['category']] ??
        [
          'Ürünü kullanmadan önce cildinizi temizleyin',
          'Az miktarda alarak istediğiniz bölgeye uygulayın',
          'Eşit şekilde yayın ve blendleyin',
        ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Adım Adım Kullanım Rehberi',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...steps.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${entry.key + 1}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.value,
                    style: const TextStyle(color: Colors.black87, height: 1.4, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.camera_alt, color: Colors.blue[700], size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('İpucu', style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(
                      'Sanal Makyaj özelliğimizi kullanarak ürünü satın almadan önce yüzünüzde deneyebilirsiniz!',
                      style: TextStyle(color: Colors.blue[800], height: 1.3, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsTab(Map<String, dynamic> product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Kullanıcı Yorumları', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text('${product['rating']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(width: 4),
                Text('(${product['reviews']})', style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._userReviews.map(
          (review) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.only(bottom: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(review['user'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(width: 8),
                    if (review['verified'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Onaylanmış Alıcı',
                          style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.w500),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          Icons.star,
                          size: 12,
                          color: index < review['rating'] ? Colors.amber : Colors.grey[200],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(review['date'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(review['comment'], style: const TextStyle(color: Colors.black87, height: 1.4, fontSize: 13)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.thumb_up_alt_outlined, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('Yardımcı oldu (${review['helpful']})', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            side: const BorderSide(color: Colors.black),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size(double.infinity, 44),
          ),
          child: const Text('Tüm Yorumları Gör'),
        ),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Icon(icon, size: 16, color: Colors.black),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? Colors.black : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.grey[500],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final String value;

  const _InfoPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text('$label:', style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
        ],
      ),
    );
  }
}