import 'package:aaraa_kart/presentation/common/my_app_nav_bar.dart';
import 'package:aaraa_kart/presentation/history/history_screen.dart';
import 'package:aaraa_kart/presentation/home/home_screen.dart';
import 'package:aaraa_kart/presentation/subscriptions/subscriptions_screen.dart';
import 'package:aaraa_kart/presentation/wallet/wallet_screen.dart';
import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  final int selectedIndex;

  const BottomNavBar({super.key, required this.selectedIndex});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int selectedIndex = 0;

  @override
  void initState() {
    selectedIndex = widget.selectedIndex;
    super.initState();
  }

  _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const SubscriptionScreen();
      case 2:
        return const OrderHistoryScreen();

      default:
        return const WalletScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: _onItemTapped(selectedIndex),
        bottomNavigationBar: MyAppNavBar(
          currentIndex: selectedIndex,
          onTap: (index) => setState(() => selectedIndex = index),
        ));
  }
}


