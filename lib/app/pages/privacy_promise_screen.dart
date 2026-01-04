import 'package:flutter/material.dart';
import 'package:mindmate_ai/app/pages/profile_setup_screen.dart';

import '../../core/utils/colors.dart';
import '../../core/utils/styles.dart';

class PrivacyPromiseScreen extends StatelessWidget {
  const PrivacyPromiseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 448),
            child: Column(
              children: [
                // Fixed Top App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back),
                        color: AppColors.textWhite,
                        iconSize: 24,
                      ),
                      Expanded(
                        child: Text(
                          'Privacy Promise',
                          style: AppStyles.heading3.copyWith(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48), // Balance the back button
                    ],
                  ),
                ),

                // Scrollable Content
                Expanded(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              const SizedBox(height: 32),

                              // Hero Illustration
                              SizedBox(
                                width: 192,
                                height: 192,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Glowing background
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryOverlay20,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    // Icon Container
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceDarkOverlay50,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.primaryOverlay10,
                                          width: 1,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: Image.network(
                                          'https://lh3.googleusercontent.com/aida-public/AB6AXuD_aLvQerzKbMNwI3WTScEJYukr12HqbUEQ3nzD8khAZyIcO3IfhXjqI8rPP08gJC96RopkeJe7sKqsqvLr_Z11EFn1AUgyMJ7XIppjpa3HaQv_iPEg3S7yX4GSNH8HkpEmv4q4z1Zm-dGw4DrM2kvK0RXqFKMHWdHJMY196RYsKqQ8BDYwdnjGuLjEJgOlD8r-YCimG5OXQwq5iu54nHTIi0TjaugI5KZKpMF5Z0wrWn9KWJqjd8NiF1RMI1Jd-J2fMq9GdyhCpy8N',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Headline
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: AppStyles.heading1,
                                  children: const [
                                    TextSpan(text: 'Your Secrets\nare '),
                                    TextSpan(
                                      text: 'Safe',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                'Before we start, here\'s how we keep your thoughts private and secure.',
                                textAlign: TextAlign.center,
                                style: AppStyles.bodyLarge.copyWith(
                                  color: AppColors.textWhite60,
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Promise List Items
                              const _PrivacyFeatureCard(
                                icon: Icons.lock,
                                title: 'Just between us',
                                description:
                                    'Your chats are encrypted end-to-end, meaning no one else can read them.',
                              ),

                              const SizedBox(height: 16),

                              const _PrivacyFeatureCard(
                                icon: Icons.cloud_off,
                                title: 'You\'re anonymous',
                                description:
                                    'We don\'t track who you are, where you live, or identify you personally.',
                              ),

                              const SizedBox(height: 16),

                              const _PrivacyFeatureCard(
                                icon: Icons.delete_sweep,
                                title: 'You\'re in control',
                                description:
                                    'Delete your chat history or reset your companion memory whenever you want.',
                              ),

                              const SizedBox(
                                height: 120,
                              ), // Space for bottom button
                            ],
                          ),
                        ),
                      ),

                      // Fixed Bottom Action Area
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.backgroundDark.withAlpha(0),
                                AppColors.backgroundDark.withAlpha(95),
                                AppColors.backgroundDark,
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
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
                                            ProfileSetupScreen(),
                                      ),
                                    );
                                  },
                                  style: AppStyles.primaryButtonStyle.copyWith(
                                    backgroundColor: WidgetStateProperty.all(
                                      AppColors.primary,
                                    ),
                                    shadowColor: WidgetStateProperty.all(
                                      AppColors.primary.withAlpha(20),
                                    ),
                                    elevation: WidgetStateProperty.all(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Got it, I\'m safe',
                                        style: AppStyles.buttonLarge,
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.check_circle, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextButton(
                                onPressed: () {
                                  // Open privacy policy
                                },
                                child: Text(
                                  'Read full Privacy Policy',
                                  style: AppStyles.bodySmall.copyWith(
                                    color: AppColors.textWhite60,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrivacyFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PrivacyFeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: AppStyles.radiusLarge,
        border: Border.all(color: AppColors.whiteOverlay5, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryOverlay10,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),

          const SizedBox(width: 16),

          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppStyles.bodyMedium.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppStyles.bodySmall.copyWith(
                    color: AppColors.textWhite60,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
