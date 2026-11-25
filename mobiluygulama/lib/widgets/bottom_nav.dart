import 'package:flutter/material.dart';

import '../theme.dart';

class BottomNav extends StatelessWidget {
  final String currentScreen;
  final Function(String) onNavigate;

  const BottomNav({
    super.key,
    required this.currentScreen,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = [
      _NavItem(id: 'home', icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Ana Sayfa'),
      _NavItem(id: 'facescan', icon: Icons.center_focus_weak, activeIcon: Icons.center_focus_strong, label: 'Tarama'),
      _NavItem(id: 'virtualmakeup', icon: Icons.brush_outlined, activeIcon: Icons.brush, label: 'Makyaj'),
      _NavItem(id: 'products', icon: Icons.shopping_bag_outlined, activeIcon: Icons.shopping_bag, label: 'Mağaza'),
      _NavItem(id: 'profile', icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profil'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))), 
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: navItems.map((item) {
              final selected = currentScreen == item.id;
              return GestureDetector(
                onTap: () => onNavigate(item.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? Colors.black : Colors.transparent,
                    borderRadius: BorderRadius.circular(12), 
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        selected ? item.activeIcon : item.icon,
                        size: 20, 
                        color: selected ? Colors.white : Colors.grey[600],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10, 
                          fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
                          color: selected ? Colors.white : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String id;
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.id,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}