import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/utils/colors.dart';
import '../../core/utils/styles.dart';
import 'privacy_promise_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  int _currentPage = 0;
  Timer? _autoScrollTimer;

  final List<OnboardingData> _pages = [
    OnboardingData(
      badgeIcon: Icons.favorite,
      badgeText: 'Always here for you',
      title: 'Hey there!\nI\'m MindMate.ai ',
      emoji: '💙',
      description:
          'I\'m here to listen, help you figure things out, or just hang out. No judgment, ever.',
    ),
    OnboardingData(
      badgeIcon: Icons.shield,
      badgeText: 'Your private sanctuary',
      title: 'Your safe space to\nexpress yourself',
      emoji: '',
      description:
          'Share your thoughts, feelings, and experiences in a judgment-free environment built just for you.',
    ),
    OnboardingData(
      badgeIcon: Icons.access_time,
      badgeText: 'Here 24/7 for you',
      title: 'Personalized support,\nanytime',
      emoji: '',
      description:
          'Whether you need to vent, seek guidance, or simply chat - I\'m here 24/7, ready to listen.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _controller.forward();

    // Start auto-scroll timer
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        _currentPage = (_currentPage + 1) % _pages.length;
      });
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentData = _pages[_currentPage];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 448),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primaryOverlay20,
                              borderRadius: AppStyles.radiusSmall,
                            ),
                            child: const Icon(
                              Icons.spa,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('MindMate', style: AppStyles.logoText),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          // Skip action
                        },
                        child: Text(
                          'Skip',
                          style: AppStyles.bodyMedium.copyWith(
                            color: AppColors.textWhite60,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content Area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Hero Illustration
                        SizedBox(
                          width: 320,
                          height: 320,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Background blobs
                              Positioned.fill(
                                child: Transform.scale(
                                  scale: 1.2,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryOverlay10,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 40,
                                right: 40,
                                child: Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    color: AppColors.lavenderOverlay20,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 40,
                                left: 40,
                                child: Container(
                                  width: 128,
                                  height: 128,
                                  decoration: BoxDecoration(
                                    color: AppColors.skyOverlay20,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),

                              // Main card
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceDarkOverlay50,
                                  borderRadius: AppStyles.radiusXLarge,
                                  border: Border.all(
                                    color: AppColors.whiteOverlay5,
                                  ),
                                  boxShadow: AppStyles.shadowMedium,
                                ),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: AppStyles.radiusXLarge,
                                      child: Image.network(
                                        'https://lh3.googleusercontent.com/aida-public/AB6AXuBqz2aDbirSV43mqz8q2cP4GiEJBlwGu4GQoaORs5SaCyjz6oPTuMxmc5tv6HaXL_H4eP5NImUFHREP5qOluO6v_X4mGV6uxTxC4eNUkS9Wx7VqxFcyVHJkXQrbwMsIQEAlGDHd75Ik4ziVD-9HEGSA07FKS21MMIqe4aKPGr5CrzyulrxAdH4nclwIzCyJvT6lZ8fBFgps1fdbTKU8kC2UOPNN1-5xa6nYtur5_IdRAF1zjn_dPuC10gKJ1VSBJ4P4OGvfc175nl1M',
                                        fit: BoxFit.cover,
                                        opacity: const AlwaysStoppedAnimation(
                                          0.9,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 24,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          child: Container(
                                            key: ValueKey(_currentPage),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.whiteOverlay10,
                                              borderRadius:
                                                  AppStyles.radiusMedium,
                                              border: Border.all(
                                                color: AppColors.whiteOverlay10,
                                              ),
                                              boxShadow: AppStyles.shadowSoft,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  currentData.badgeIcon,
                                                  color: AppColors.primary,
                                                  size: 14,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  currentData.badgeText,
                                                  style: AppStyles.bodySmall,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Text Content - Changes with animation
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Column(
                            key: ValueKey(_currentPage),
                            children: [
                              if (currentData.emoji.isNotEmpty)
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: AppStyles.heading1,
                                    children: [
                                      TextSpan(text: currentData.title),
                                      TextSpan(
                                        text: currentData.emoji,
                                        style: const TextStyle(fontSize: 28),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Text(
                                  currentData.title,
                                  textAlign: TextAlign.center,
                                  style: AppStyles.heading1,
                                ),
                              const SizedBox(height: 8),
                              Text(
                                currentData.description,
                                textAlign: TextAlign.center,
                                style: AppStyles.bodyLarge,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Dots Indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_pages.length, (index) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: _currentPage == index ? 24 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? AppColors.primary
                                    : AppColors.whiteOverlay20,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 32),

                        // Static Buttons - These never move
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const PrivacyPromiseScreen(),
                                    ),
                                  );
                                },
                                style: AppStyles.primaryButtonStyle,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Start Journey',
                                      style: AppStyles.buttonLarge,
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward, size: 20),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: TextButton(
                                onPressed: () {
                                  // Navigate to login
                                },
                                style: AppStyles.secondaryButtonStyle,
                                child: Text(
                                  'I already have an account',
                                  style: AppStyles.buttonMedium.copyWith(
                                    color: AppColors.textWhite60,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Footer
                Container(height: 8, color: AppColors.backgroundDark),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingData {
  final IconData badgeIcon;
  final String badgeText;
  final String title;
  final String emoji;
  final String description;

  OnboardingData({
    required this.badgeIcon,
    required this.badgeText,
    required this.title,
    required this.emoji,
    required this.description,
  });
}
