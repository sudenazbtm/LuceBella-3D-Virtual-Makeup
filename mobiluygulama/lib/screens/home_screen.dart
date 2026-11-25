import 'package:flutter/material.dart';

import '../widgets/aibot.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/logo.dart';

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic>? user;
  final Function(String) onNavigate;

  const HomeScreen({
    super.key,
    required this.user,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Logo(variant: 'light', size: 'md', onClick: () => onNavigate('home')),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => onNavigate('cart'),
                        icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                        tooltip: 'Sepet',
                        style: IconButton.styleFrom(
                          hoverColor: Colors.white.withOpacity(0.1),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => onNavigate('settings'),
                        icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
                        tooltip: 'Ayarlar',
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
          ),
          
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Hero(onNavigate: onNavigate),
                  _QuickActions(onNavigate: onNavigate),
                  _FeaturedCollections(onNavigate: onNavigate),
                  _Categories(onNavigate: onNavigate),
                  const _StatsSection(),
                  _CtaSection(onNavigate: onNavigate),
                  const SizedBox(height: 80), 
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentScreen: 'home',
        onNavigate: onNavigate,
      ),
      floatingActionButton: const AIBotAction(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _Hero extends StatelessWidget {
  final Function(String) onNavigate;

  const _Hero({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Stack(
        fit: StackFit.expand,
        children: [
          
          Image.network(
            'https://images.unsplash.com/photo-1616683693504-3ea7e9ad6fec?q=80&w=1200&auto=format&fit=crop',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[900]),
          ),
          
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.black54, Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: const Text(
                    'YAPAY ZEKA DESTEKLİ GÜZELLİK',
                    style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Güzelliğinizi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                ),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, Color(0xFFE5E7EB), Colors.white],
                  ).createShader(bounds),
                  child: const Text(
                    'Yeniden Keşfedin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'AI destekli sanal makyaj ile kişiselleştirilmiş güzellik deneyimi',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => onNavigate('virtualmakeup'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Sanal Makyajı Dene', style: TextStyle(fontWeight: FontWeight.w500)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => onNavigate('products'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withOpacity(0.3), width: 2),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Alışverişe Başla'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final Function(String) onNavigate;

  const _QuickActions({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hızlı Erişim', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black)),
          const SizedBox(height: 8),
          const Text('AI destekli özellikler', style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isDesktop = width > 600;
              
              if (!isDesktop) {
                 return SingleChildScrollView(
                   scrollDirection: Axis.horizontal,
                   child: Row(
                     children: [
                       SizedBox(
                         width: 260,
                         child: _QuickActionCard(
                           icon: Icons.center_focus_strong,
                           label: 'Yüz Analizi',
                           description: 'Cilt tipini belirle',
                           gradientColors: const [Colors.purple, Colors.pink],
                           onTap: () => onNavigate('facescan'),
                         ),
                       ),
                       const SizedBox(width: 16),
                       SizedBox(
                         width: 260,
                         child: _QuickActionCard(
                           icon: Icons.brush,
                           label: 'Sanal Makyaj',
                           description: 'AI destekli deneyim',
                           gradientColors: const [Colors.blue, Colors.cyan],
                           onTap: () => onNavigate('virtualmakeup'),
                         ),
                       ),
                       const SizedBox(width: 16),
                       SizedBox(
                         width: 260,
                         child: _QuickActionCard(
                           icon: Icons.shopping_bag,
                           label: 'Ürün Kataloğu',
                           description: '60+ premium ürün',
                           gradientColors: const [Colors.orange, Colors.red],
                           onTap: () => onNavigate('products'),
                         ),
                       ),
                     ],
                   ),
                 );
              }

              return Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.center_focus_strong,
                      label: 'Yüz Analizi',
                      description: 'Cilt tipini belirle',
                      gradientColors: const [Colors.purple, Colors.pink],
                      onTap: () => onNavigate('facescan'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.brush,
                      label: 'Sanal Makyaj',
                      description: 'AI destekli deneyim',
                      gradientColors: const [Colors.blue, Colors.cyan],
                      onTap: () => onNavigate('virtualmakeup'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.shopping_bag,
                      label: 'Ürün Kataloğu',
                      description: '60+ premium ürün',
                      gradientColors: const [Colors.orange, Colors.red],
                      onTap: () => onNavigate('products'),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 16),
            Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black)),
            const SizedBox(height: 4),
            Text(description, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _FeaturedCollections extends StatelessWidget {
  final Function(String) onNavigate;

  const _FeaturedCollections({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final collections = [
      {
        'title': 'En Çok Satılanlar',
        'subtitle': 'Çok Satanlar',
        'image': 'https://images.unsplash.com/photo-1651686534008-586855ac1547?w=800',
        'badge': 'En İyi',
        'badgeIcon': Icons.star,
      },
      {
        'title': 'Yeni Gelenler',
        'subtitle': 'Yeni Gelenler',
        'image': 'https://images.unsplash.com/photo-1560879311-370fd4561a0d?w=800',
        'badge': 'Yeni',
        'badgeIcon': Icons.auto_awesome,
      },
      {
        'title': 'Trend Ürünler',
        'subtitle': 'Trendler',
        'image': 'https://images.unsplash.com/photo-1759695408177-f552293d5afd?w=800',
        'badge': 'Trend',
        'badgeIcon': Icons.trending_up,
      },
    ];

    return Container(
      color: Colors.grey[50],
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Öne Çıkan Koleksiyonlar', 
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text('LuceBella seçkileri', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => onNavigate('products'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Tümünü Gör', style: TextStyle(color: Colors.black, fontSize: 13)),
                    Icon(Icons.chevron_right, size: 16, color: Colors.black),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth > 600;
              if (!isDesktop) {
                return SizedBox(
                  height: 220,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: collections.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: 150,
                        child: _buildCollectionCard(collections[index], false),
                      );
                    },
                  ),
                );
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: collections.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 3/4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, index) => _buildCollectionCard(collections[index], true),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionCard(Map<String, dynamic> col, bool isDesktop) {
    return GestureDetector(
      onTap: () => onNavigate('products'),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              col['image'] as String,
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) => Container(color: Colors.grey),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black54, Colors.black87],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(col['subtitle'] as String, style: TextStyle(color: Colors.white70, fontSize: isDesktop ? 10 : 9, letterSpacing: 1.0, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(col['title'] as String, style: TextStyle(color: Colors.white, fontSize: isDesktop ? 20 : 14, fontWeight: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(col['badgeIcon'] as IconData, size: 10, color: Colors.black),
                    const SizedBox(width: 4),
                    Text(col['badge'] as String, style: const TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Categories extends StatelessWidget {
  final Function(String) onNavigate;

  const _Categories({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'Ruj', 'icon': '💄', 'count': '6 ürün'},
      {'name': 'Fondöten', 'icon': '🧴', 'count': '6 ürün'},
      {'name': 'Allık', 'icon': '🌸', 'count': '6 ürün'},
      {'name': 'Far', 'icon': '👁️', 'count': '6 ürün'},
      {'name': 'Eyeliner', 'icon': '✏️', 'count': '6 ürün'},
      {'name': 'Maskara', 'icon': '👀', 'count': '6 ürün'},
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           const Text('Kategoriler', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black)),
           const SizedBox(height: 8),
           const Text('60+ premium ürün', style: TextStyle(color: Colors.grey, fontSize: 16)),
           const SizedBox(height: 32),
           LayoutBuilder(
             builder: (context, constraints) {
               final isDesktop = constraints.maxWidth > 600;
               return GridView.builder(
                 shrinkWrap: true,
                 physics: const NeverScrollableScrollPhysics(),
                 itemCount: categories.length,
                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                   crossAxisCount: isDesktop ? 3 : 2,
                   childAspectRatio: isDesktop ? 1.5 : 2.5,
                   crossAxisSpacing: 16,
                   mainAxisSpacing: 16,
                 ),
                 itemBuilder: (context, index) {
                   final cat = categories[index];
                   return GestureDetector(
                     onTap: () => onNavigate('products'),
                     child: Container(
                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                       decoration: BoxDecoration(
                         color: Colors.white,
                         borderRadius: BorderRadius.circular(12),
                         border: Border.all(color: Colors.grey.shade200),
                       ),
                       child: Row(
                         children: [
                           Text(cat['icon']!, style: const TextStyle(fontSize: 28)),
                           const SizedBox(width: 12),
                           Expanded(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 Text(cat['name']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                                 Text(cat['count']!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                               ],
                             ),
                           ),
                         ],
                       ),
                     ),
                   );
                 },
               );
             },
           ),
        ],
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(value: '60+', label: 'Premium Ürün'),
          _StatItem(value: '3D', label: 'AI Teknoloji'),
          _StatItem(value: 'AI', label: 'Yapay Zeka'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14, letterSpacing: 0.5)),
      ],
    );
  }
}

class _CtaSection extends StatelessWidget {
  final Function(String) onNavigate;

  const _CtaSection({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Colors.black, Color(0xFF111827)], 
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.white70, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Kişiselleştirilmiş\nGüzellik Deneyimi',
              style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'AI destekli cilt analizi ile size özel ürün önerileri',
              style: TextStyle(color: Colors.grey, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => onNavigate('facescan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Cilt Analizine Başla', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }
}