import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../theme.dart';
import '../widgets/aibot.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/logo.dart';

class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? user;
  final Function(String, {dynamic data}) onNavigate;
  final Function(Map<String, dynamic>) onUpdateUser;
  final List<dynamic> likedProducts;
  final Function(dynamic) onToggleLike;

  const ProfileScreen({
    super.key,
    required this.user,
    required this.onNavigate,
    required this.onUpdateUser,
    required this.likedProducts,
    required this.onToggleLike,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _activeTab = 0; 

  
  String _skinType = '';
  List<String> _skinConditions = [];
  bool _saved = false;

  
  bool _isEditingInfo = false;
  late TextEditingController _userNameController;
  late TextEditingController _userEmailController;
  late TextEditingController _userPhoneController;
  late TextEditingController _userBirthdayController;
  late TextEditingController _userAddressController;

  
  bool _showPasswordChange = false;
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  final List<String> _skinTypes = ['Yağlı', 'Kuru', 'Karma', 'Normal'];
  
  final List<String> _conditions = [
    'Akne',
    'Akneye Meyilli',
    'Sivilceli',
    'Rozalı',
    'Kızarık',
    'Hassas',
    'Lekeli',
    'Gözenekli'
  ];

  @override
  void initState() {
    super.initState();
    _skinType = widget.user?['skinType'] ?? '';
    _skinConditions = List<String>.from(widget.user?['skinConditions'] ?? []);
    
    _userNameController = TextEditingController(text: widget.user?['name'] ?? '');
    _userEmailController = TextEditingController(text: widget.user?['email'] ?? '');
    _userPhoneController = TextEditingController(text: widget.user?['phone'] ?? '');
    _userBirthdayController = TextEditingController(text: widget.user?['birthday'] ?? '');
    _userAddressController = TextEditingController(text: widget.user?['address'] ?? '');
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _userEmailController.dispose();
    _userPhoneController.dispose();
    _userBirthdayController.dispose();
    _userAddressController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleCondition(String condition) {
    setState(() {
      if (_skinConditions.contains(condition)) {
        _skinConditions.remove(condition);
      } else {
        _skinConditions.add(condition);
      }
    });
  }

  Future<void> _handleSave() async {
    final updatedUser = {
      ...widget.user ?? {},
      'skinType': _skinType,
      'skinConditions': _skinConditions,
    };
    widget.onUpdateUser(updatedUser);
    
    
    
    

    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  Future<void> _handleSaveUserInfo() async {
    final updatedUser = {
      ...widget.user ?? {},
      'name': _userNameController.text,
      'email': _userEmailController.text,
      'phone': _userPhoneController.text,
      'birthday': _userBirthdayController.text,
      'address': _userAddressController.text,
    };
    widget.onUpdateUser(updatedUser);
    
    setState(() {
      _isEditingInfo = false;
      _saved = true;
    });
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  void _handleChangePassword() {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yeni şifreler eşleşmiyor!')),
      );
      return;
    }
    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Şifre en az 6 karakter olmalıdır!')),
      );
      return;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Şifreniz başarıyla değiştirildi!')),
    );
    
    setState(() {
      _showPasswordChange = false;
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: const AIBotAction(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildUserCard(),
                    const SizedBox(height: 24),
                    _buildTabBar(),
                    const SizedBox(height: 24),
                    _buildActiveTab(),
                    const SizedBox(height: 80), 
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentScreen: 'profile',
        onNavigate: widget.onNavigate,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => widget.onNavigate('home'),
            child: const Logo(variant: 'light', size: 'md'),
          ),
          IconButton(
            onPressed: () => setState(() => _activeTab = 2), 
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard() {
    final name = widget.user?['name'] ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';
    
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          name.isNotEmpty ? name : 'Kullanıcı',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        const SizedBox(height: 4),
        Text(
          widget.user?['email'] ?? '',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          _TabItem(
            icon: Icons.person_outline,
            label: 'Profil',
            isActive: _activeTab == 0,
            onTap: () => setState(() => _activeTab = 0),
          ),
          _TabItem(
            icon: Icons.favorite_border,
            label: 'Beğenilenler',
            badge: widget.likedProducts.length > 0 ? '${widget.likedProducts.length}' : null,
            isActive: _activeTab == 1,
            onTap: () => setState(() => _activeTab = 1),
          ),
          _TabItem(
            icon: Icons.settings_outlined,
            label: 'Ayarlar',
            isActive: _activeTab == 2,
            onTap: () => setState(() => _activeTab = 2),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTab() {
    switch (_activeTab) {
      case 0:
        return _buildProfileTab();
      case 1:
        return _buildLikedTab();
      case 2:
        return _buildSettingsTab();
      default:
        return _buildProfileTab();
    }
  }

  Widget _buildProfileTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Kişisel Bilgiler', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            TextButton.icon(
              onPressed: () => setState(() => _isEditingInfo = !_isEditingInfo),
              icon: Icon(_isEditingInfo ? Icons.close : Icons.edit_outlined, size: 16, color: Colors.grey[600]),
              label: Text(
                _isEditingInfo ? 'İptal' : 'Düzenle',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        
        _buildInfoField('Ad Soyad', Icons.person_outline, _userNameController, isEditing: _isEditingInfo),
        const SizedBox(height: 12),
        _buildInfoField('E-posta', Icons.email_outlined, _userEmailController, isEditing: _isEditingInfo, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 12),
        _buildInfoField('Telefon', Icons.phone_outlined, _userPhoneController, isEditing: _isEditingInfo, keyboardType: TextInputType.phone, hint: '+90 (XXX) XXX XX XX'),
        const SizedBox(height: 12),
        _buildInfoField('Doğum Tarihi', Icons.calendar_today_outlined, _userBirthdayController, isEditing: _isEditingInfo, keyboardType: TextInputType.datetime),
        const SizedBox(height: 12),
        _buildInfoField('Adres', Icons.location_on_outlined, _userAddressController, isEditing: _isEditingInfo, maxLines: 2),

        if (_isEditingInfo) ...[
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _handleSaveUserInfo,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Bilgileri Kaydet'),
          ),
        ],

        const SizedBox(height: 32),
        
        
        const Text('Cilt Tipiniz', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _skinTypes.length,
          itemBuilder: (context, index) {
            final type = _skinTypes[index];
            final isSelected = _skinType == type;
            return GestureDetector(
              onTap: () => setState(() => _skinType = type),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.white,
                  border: Border.all(color: isSelected ? Colors.black : Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  type,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 32),

        
        const Text('Cilt Durumunuz', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('Birden fazla seçebilirsiniz', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _conditions.length,
          itemBuilder: (context, index) {
            final condition = _conditions[index];
            final isSelected = _skinConditions.contains(condition);
            return GestureDetector(
              onTap: () => _toggleCondition(condition),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.white,
                  border: Border.all(color: isSelected ? Colors.black : Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      condition,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check, color: Colors.white, size: 18),
                  ],
                ),
              ),
            );
          },
        ),

        
        if (_skinConditions.isNotEmpty) ...[
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kaçınmanız Gereken İçerikler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                if (_skinConditions.contains('Akne'))
                  _buildWarningItem('Akne', 'Komedojenik yağlar, heavy silikon'),
                if (_skinConditions.contains('Hassas'))
                  _buildWarningItem('Hassas Cilt', 'Parfüm, alkol, retinol'),
                if (_skinConditions.contains('Rozalı'))
                  _buildWarningItem('Rozalı', 'AHA/BHA, mentol, kafein'),
                if (_skinConditions.contains('Kuru')) 
                  _buildWarningItem('Kuru Cilt', 'Sülfat, alkol bazlı ürünler'),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_saved) const Icon(Icons.check, size: 20),
              if (_saved) const SizedBox(width: 8),
              Text(_saved ? 'Kaydedildi!' : 'Cilt Bilgilerini Kaydet', style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWarningItem(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.grey[800], fontSize: 14),
          children: [
            const TextSpan(text: '• ', style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: content),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, IconData icon, TextEditingController controller, {
    bool isEditing = false,
    TextInputType? keyboardType,
    String? hint,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            ],
          ),
          if (isEditing) ...[
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              decoration: InputDecoration(
                hintText: hint,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black)),
              ),
            ),
          ] else ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(
                controller.text.isNotEmpty ? controller.text : 'Belirtilmemiş',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLikedTab() {
    if (widget.likedProducts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            children: [
              Icon(Icons.favorite_border, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text('Henüz beğendiğiniz ürün yok', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => widget.onNavigate('products'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Ürünleri Keşfet'),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.65,
      ),
      itemCount: widget.likedProducts.length,
      itemBuilder: (context, index) {
        final product = widget.likedProducts[index];
        return _LikedProductCard(
          product: Map<String, dynamic>.from(product),
          onTap: () => widget.onNavigate('productdetail', data: product),
          onUnlike: () => widget.onToggleLike(product),
        );
      },
    );
  }

  Widget _buildSettingsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Hesap Ayarları', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 24),
        
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () => setState(() => _showPasswordChange = !_showPasswordChange),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Şifre Değiştir', style: TextStyle(fontWeight: FontWeight.w500)),
                    Icon(_showPasswordChange ? Icons.remove : Icons.add, color: Colors.grey),
                  ],
                ),
              ),
              if (_showPasswordChange) ...[
                const SizedBox(height: 16),
                _buildPasswordField('Mevcut Şifre', _currentPasswordController, _showCurrentPassword, () => setState(() => _showCurrentPassword = !_showCurrentPassword)),
                const SizedBox(height: 12),
                _buildPasswordField('Yeni Şifre', _newPasswordController, _showNewPassword, () => setState(() => _showNewPassword = !_showNewPassword)),
                const SizedBox(height: 12),
                _buildPasswordField('Yeni Şifre (Tekrar)', _confirmPasswordController, _showConfirmPassword, () => setState(() => _showConfirmPassword = !_showConfirmPassword)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleChangePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Şifreyi Güncelle'),
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),
        
        const Text('Bildirim Tercihleri', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildSwitchItem('E-posta Bildirimleri'),
        const SizedBox(height: 12),
        _buildSwitchItem('Ürün Önerileri'),
        const SizedBox(height: 12),
        _buildSwitchItem('Kampanya Bildirimleri'),

        const SizedBox(height: 24),
        const Text('Gizlilik', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildActionItem('Gizlilik Politikası'),
        const SizedBox(height: 12),
        _buildActionItem('Kullanım Koşulları'),
        const SizedBox(height: 12),
        _buildActionItem('Verilerimi İndir'),
        const SizedBox(height: 12),
        _buildActionItem('Hesabı Sil', isDestructive: true),
        
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            
            widget.onNavigate('login');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            side: const BorderSide(color: Colors.grey),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            minimumSize: const Size(double.infinity, 0),
          ),
          child: const Text('Çıkış Yap'),
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool obscure, VoidCallback onToggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: !obscure,
          decoration: InputDecoration(
            hintText: '••••••••',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black)),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchItem(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Switch(value: true, onChanged: (_) {}, activeColor: Colors.black),
        ],
      ),
    );
  }

  Widget _buildActionItem(String label, {bool isDestructive = false}) {
    return InkWell(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red[50] : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isDestructive ? Colors.red[600] : Colors.grey[700],
            fontWeight: isDestructive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    this.badge,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? Colors.black : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: isActive ? Colors.black : Colors.grey[500]),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isActive ? Colors.black : Colors.grey[500],
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.black : Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LikedProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onTap;
  final VoidCallback onUnlike;

  const _LikedProductCard({
    required this.product,
    required this.onTap,
    required this.onUnlike,
  });

  @override
  Widget build(BuildContext context) {
    Color parseColor(String colorString) {
      try {
        return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
      } catch (e) {
        return Colors.grey;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: product['image'] ?? '',
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(color: Colors.grey[200]),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: parseColor(product['color'] ?? '#000000'),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['brand'] ?? '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 10),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product['name'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text('${product['rating']}', style: TextStyle(color: Colors.grey[700], fontSize: 11)),
                          const SizedBox(width: 2),
                          Text('(${product['reviews']})', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product['priceText'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              left: 8,
              child: GestureDetector(
                onTap: onUnlike,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: const Icon(Icons.favorite, size: 16, color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}