import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mindmate_ai/app/pages/dashboard_screen.dart';
import '../../core/services/shared_preferences_service.dart';
import '../../core/utils/colors.dart';
import '../../core/utils/styles.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  int _selectedAvatarIndex = 0;
  int _selectedAgeRangeIndex = 1; // Default to 16-17

  final List<AvatarOption> _avatars = [
    AvatarOption(
      name: 'Kitty',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB1RgSZjiG97uvxCXxQuRAP5eHf7Bk5-hDomQKsDeQLpiMpgUHla9p4Tg8wzRbeKTxOnCc7o5r2ceSLfST-_wpba6D-CZ8hqTqlwFFbOkQguozWxVBfs-5B-yoXnj-6srrdmSzaeive2m7BPDbeaOHDuK_KYYtf-VpqI66KpOfheEYFAg0pmVo-2sNAK71-QwQj0aea8Wz9wVvqITI8ErqIQ9iClZrK04Kenu7QRqY-qir4Hj59cqP1QbVPrs3lJBvGnHi8T0U0eG8t',
    ),
    AvatarOption(
      name: 'Bear',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAiWUNeZrJgQeg4y7ehVwmT-gYhr27-80l5VC5uk96OF-5wYq4ocxNrMCxmBl0WFvcOy9GZusS-uCHf2lEFag0MWABeI6tHLm7J6YY6O2eAVc13JFWBafGX7mrIHV7lvlyGR8y6_I2eX4Rf_nuJrLj7e9g1pWp37i4CA7FqnEk73TYUzF-WoDjIm4VZ6gCUOBLLppdS_dc1obGLHLNFMsTBzwpnHfbziPX52Y2L-hRLNKbjYRqN8ts0UunXycQ5Y9d36INH_ovYCY4T',
    ),
    AvatarOption(
      name: 'Fox',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA82m0bzyiZkkj3MxqzVoCQj1SOoBIZg4kk2ohp8xoWrG2YLdgDlzSTd658mJR0-Pmdk8s0WckvImQI8Q-6hK5gEqyVWl8gYjrnP1Vx-n7ogAbjHD17fmLhDjiBx4HWzuP6975KVa8bepFsDBBrWra5BpbLMPWBalyhmmybc2kgo84n5H-2inQ070Iq2tLEcM3wSnRjd3Vg16_Pqbb-2_WoqsQMkc-vMJk3svIvLTHJ94Kd0hEg9Q438YvnD4kqQer0LABleJ5KrMF8',
    ),
  ];

  final List<AgeRangeOption> _ageRanges = [
    AgeRangeOption(range: '13-15', label: 'YOUNG TEEN'),
    AgeRangeOption(range: '16-17', label: 'MID TEEN'),
    AgeRangeOption(range: '18-19', label: 'YOUNG ADULT'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();

    // Validate name is not empty
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final avatar = _avatars[_selectedAvatarIndex];
    final ageRange = _ageRanges[_selectedAgeRangeIndex];

    // Save to SharedPreferences using the service
    final prefs = await SharedPrefsService.getInstance();
    final success = await prefs.saveUserProfile(
      name: name,
      avatarName: avatar.name,
      avatarUrl: avatar.imageUrl,
      ageRange: ageRange.range,
      ageLabel: ageRange.label,
    );

    if (success) {
      log(
        'Profile saved - Name: $name, Avatar: ${avatar.name}, Age: ${ageRange.range}',
      );

      // Navigate to dashboard
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      }
    } else {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 448),
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.whiteOverlay5,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            color: AppColors.textWhite,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable Content
                Expanded(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),

                            // Headline
                            RichText(
                              text: TextSpan(
                                style: AppStyles.heading1.copyWith(
                                  fontSize: 30,
                                ),
                                children: const [
                                  TextSpan(text: 'Let\'s vibe check.\n'),
                                  TextSpan(
                                    text: 'Who are you?',
                                    style: TextStyle(color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'Customize your profile so MindMate knows who it\'s chatting with. You can keep it anon if you want.',
                              style: AppStyles.bodyLarge.copyWith(
                                color: AppColors.textWhite60,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Avatar Picker Section
                            Text(
                              'PICK AN AVATAR',
                              style: AppStyles.bodySmall.copyWith(
                                fontSize: 12,
                                color: AppColors.textWhite70,
                                letterSpacing: 1.2,
                              ),
                            ),

                            const SizedBox(height: 16),

                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _avatars.length,
                                itemBuilder: (context, index) {
                                  final isSelected =
                                      index == _selectedAvatarIndex;
                                  return _AvatarOption(
                                    avatar: _avatars[index],
                                    isSelected: isSelected,
                                    onTap: () {
                                      setState(() {
                                        _selectedAvatarIndex = index;
                                      });
                                    },
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Name Input
                            Text(
                              'WHAT SHOULD WE CALL YOU?',
                              style: AppStyles.bodySmall.copyWith(
                                fontSize: 12,
                                color: AppColors.textWhite70,
                                letterSpacing: 1.2,
                              ),
                            ),

                            const SizedBox(height: 12),

                            TextField(
                              controller: _nameController,
                              style: AppStyles.heading3.copyWith(fontSize: 18),
                              decoration: InputDecoration(
                                hintText: 'Type your name or nickname...',
                                hintStyle: AppStyles.bodyLarge.copyWith(
                                  color: AppColors.textWhite80,
                                ),
                                filled: true,
                                fillColor: AppColors.surfaceDark,
                                border: OutlineInputBorder(
                                  borderRadius: AppStyles.radiusMedium,
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: AppStyles.radiusMedium,
                                  borderSide: const BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                suffixIcon: Icon(
                                  Icons.edit,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Age Range Section
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'AGE RANGE',
                                      style: AppStyles.bodySmall.copyWith(
                                        fontSize: 12,
                                        color: AppColors.textWhite70,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryOverlay10,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Private',
                                        style: AppStyles.bodySmall.copyWith(
                                          fontSize: 10,
                                          color: AppColors.primary.withAlpha(
                                            80,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                Row(
                                  children: List.generate(_ageRanges.length, (
                                    index,
                                  ) {
                                    final isSelected =
                                        index == _selectedAgeRangeIndex;
                                    return Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          right: index < _ageRanges.length - 1
                                              ? 12
                                              : 0,
                                        ),
                                        child: _AgeRangeButton(
                                          ageRange: _ageRanges[index],
                                          isSelected: isSelected,
                                          onTap: () {
                                            setState(() {
                                              _selectedAgeRangeIndex = index;
                                            });
                                          },
                                        ),
                                      ),
                                    );
                                  }),
                                ),

                                const SizedBox(height: 12),

                                Text(
                                  'We use this to curate the right advice for your age group.',
                                  textAlign: TextAlign.center,
                                  style: AppStyles.bodySmall.copyWith(
                                    color: AppColors.textWhite80,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 120),
                          ],
                        ),
                      ),

                      // Fixed Bottom Button
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
                          child: SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _saveProfile,
                              style: AppStyles.primaryButtonStyle,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Continue',
                                    style: AppStyles.buttonLarge,
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward, size: 20),
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
        ),
      ),
    );
  }
}

// Avatar Option Widget
class _AvatarOption extends StatelessWidget {
  final AvatarOption avatar;
  final bool isSelected;
  final VoidCallback onTap;

  const _AvatarOption({
    required this.avatar,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.transparent,
                      width: 4,
                    ),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.network(avatar.imageUrl, fit: BoxFit.cover),
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.backgroundDark,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: AppColors.primaryContent,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              avatar.name,
              style: AppStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textWhite60,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Age Range Button Widget
class _AgeRangeButton extends StatelessWidget {
  final AgeRangeOption ageRange;
  final bool isSelected;
  final VoidCallback onTap;

  const _AgeRangeButton({
    required this.ageRange,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12),
            height: 100,
            width: 120,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  ageRange.range,
                  style: AppStyles.heading1.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? AppColors.primaryContent
                        : AppColors.textWhite70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ageRange.label,
                  style: AppStyles.bodySmall.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: isSelected
                        ? AppColors.primaryContent.withAlpha(70)
                        : AppColors.textWhite60,
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

// Data Models
class AvatarOption {
  final String name;
  final String imageUrl;

  AvatarOption({required this.name, required this.imageUrl});
}

class AgeRangeOption {
  final String range;
  final String label;

  AgeRangeOption({required this.range, required this.label});
}
