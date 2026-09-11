import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:iconsx_plus/iconsx_plus.dart';

class MyAppNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const MyAppNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                  0, Iconsax.home_1_bold, Iconsax.home_1_bold, 'Home'),
              _buildNavItem(1, Iconsax.calendar_bold, Iconsax.calendar_bold,
                  'Subscriptions'),
              _buildNavItem(2, Iconsax.menu_board_bold, Iconsax.menu_board_bold,
                  'Orders'),
              _buildNavItem(
                  3, Iconsax.wallet_bold, Iconsax.wallet_bold, 'Wallet'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData icon, IconData selectedIcon, String label) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.brandPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              !isSelected ? selectedIcon : icon,
              color: !isSelected
                  ? AppColors.brandPrimary
                  : AppColors.brandPrimaryDark,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: !isSelected
                    ? AppColors.brandPrimary
                    : AppColors.brandPrimaryDark,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


