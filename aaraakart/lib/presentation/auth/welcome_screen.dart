import 'package:flutter/material.dart';
import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/core/config/brand_config.dart';
import 'package:aaraa_kart/presentation/common/my_app_button.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsx_plus/iconsx_plus.dart';

class WelcomeScreen extends StatefulWidget {
  final String name;
  final String phoneNumber;
  final String email;

  const WelcomeScreen({
    super.key,
    required this.name,
    required this.phoneNumber,
    required this.email,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      bottomNavigationBar: _buildGetStartedButton(),
      body: SingleChildScrollView(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildWelcomeHeader(),
                    const SizedBox(height: 40),
                    _buildFeaturesSection(),
                    const SizedBox(height: 20),
                    _buildQuickStats(),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      children: [
        Text(
          "Hi ${widget.name}, you're all set!",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.brandPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          BrandConfig.instance.content.welcomeDescription,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      children: [
        // Features Header
        Text(
          "What's waiting for you:",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 24),

        // Features List
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                icon: Icons.eco_rounded,
                title: "Fresh Produce",
                subtitle: "Straight from farms",
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: true
                  ? _buildFeatureCard(
                      icon: Iconsax.shopping_bag_outline,
                      title: "Fast Delivery",
                      subtitle: "Right to your door",
                      color: AppColors.brandPrimary,
                    )
                  : _buildFeatureCard(
                      icon: Icons.store_rounded,
                      title: "Easy Pickup",
                      subtitle: "Collect in store",
                      color: AppColors.brandPrimary,
                    ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                icon: Icons.local_offer_rounded,
                title: "Best Prices",
                subtitle: "Direct from source",
                color: AppColors.brandSecondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFeatureCard(
                icon: Icons.support_agent_rounded,
                title: "24/7 Support",
                subtitle: "We're here to help",
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: MyAppButton(
          label: "START SHOPPING",
          onPressed: () {
            context.pushReplacement("/bottom-bar");
          },
          icon: Iconsax.shopping_bag_outline,
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            number: "500+",
            label: "Fresh Products",
            icon: Icons.inventory_rounded,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.borderDefault,
          ),
          _buildStatItem(
            number: "50+",
            label: "Local Farmers",
            icon: Icons.agriculture_rounded,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.borderDefault,
          ),
          _buildStatItem(
            number: "10K+",
            label: "Happy Customers",
            icon: Icons.sentiment_very_satisfied_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String number,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.brandPrimary,
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          number,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}


