import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/logo.dart';

class SettingsScreen extends StatelessWidget {
  final Map<String, dynamic>? user;
  final Function(String) onNavigate;
  final VoidCallback onLogout;
  final bool isDarkMode;
  final Future<void> Function(bool) onToggleTheme;

  const SettingsScreen({
    super.key,
    required this.user,
    required this.onNavigate,
    required this.onLogout,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  children: [
                    _buildAccountCard(),
                    const SizedBox(height: 24),
                    _buildSection(title: 'Hesap', items: [
                      _SettingsTile(icon: Icons.person, label: 'Profil Bilgileri', onTap: () => onNavigate('profile')),
                      _SettingsTile(icon: Icons.lock, label: 'Şifre Değiştir'),
                    ]),
                    const SizedBox(height: 18),
                    _buildSection(title: 'Tercihler', items: [
                      _SettingsTile(icon: Icons.notifications, label: 'Bildirimler', trailing: Switch(value: true, onChanged: (_) {})),
                      _SettingsTile(
                        icon: Icons.dark_mode,
                        label: 'Karanlık Tema',
                        trailing: Switch(
                          value: isDarkMode,
                          onChanged: (v) => onToggleTheme(v),
                        ),
                      ),
                      _SettingsTile(icon: Icons.language, label: 'Dil'),
                    ]),
                    const SizedBox(height: 18),
                    _buildSection(title: 'Destek', items: [
                      _SettingsTile(icon: Icons.help_outline, label: 'Yardım Merkezi'),
                      _SettingsTile(icon: Icons.info_outline, label: 'Hakkımızda'),
                    ]),
                    const SizedBox(height: 28),
                    ElevatedButton(
                      onPressed: onLogout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 8),
                          Text('Çıkış Yap'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'BeautyAI v1.0.0',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentScreen: 'settings',
        onNavigate: onNavigate,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(bottom: BorderSide(color: Colors.white24, width: 0.6)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onNavigate('home'),
            child: const Logo(variant: 'light', size: 'md'),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildAccountCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primary,
            child: Text(
              user?['name']?[0]?.toUpperCase() ?? 'U',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?['name'] ?? 'Luce Bella Kullanıcısı',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(user?['email'] ?? '-', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => onNavigate('profile'),
            child: const Text('Düzenle'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<_SettingsTile> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: items
                .map((tile) => Column(
                      children: [
                        tile,
                        if (tile != items.last) const Divider(height: 1, color: AppColors.border),
                      ],
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
