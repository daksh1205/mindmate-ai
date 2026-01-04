import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/services/shared_preferences_service.dart';
import '../../core/utils/colors.dart';
import '../../core/utils/styles.dart';
import 'call_screen.dart';
import 'chat_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedMoodIndex = 3;
  int _selectedNavIndex = 0;

  // User profile data
  String _userName = 'Alex';
  String _userAvatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuBmmigwP6Wc1LPTtGqsJVJ-kB9-tUjRWKEdMxUGOcCqStYcsHXQaao94-cxgCvUKVgPeTUYJiub3aw9qD5gTZ-jn-v10TSSAbwYisOA5SPsH_adnb2yKp4P1BZeTYTxMmP201m6L657dwNp9bUYddJGtxB71VdtX0ZpX_VzSoeedlmfsw1dUBaRzlhIfEu9jFluvJDs_p537Owcf72Ep92_hb5P06r_0zXpl3zU986bwYpwLf3qabVssIkX1sno3dX9jtvmjNKUepF0';
  bool _isLoading = true;

  final List<MoodOption> _moods = [
    MoodOption(icon: Icons.sentiment_very_dissatisfied, label: 'Very Sad'),
    MoodOption(icon: Icons.sentiment_dissatisfied, label: 'Sad'),
    MoodOption(icon: Icons.sentiment_neutral, label: 'Neutral'),
    MoodOption(icon: Icons.sentiment_satisfied, label: 'Happy'),
    MoodOption(icon: Icons.sentiment_very_satisfied, label: 'Very Happy'),
  ];

  final List<DailyTip> _dailyTips = [
    DailyTip(
      icon: Icons.self_improvement,
      title: 'Breathe In',
      description: '4-7-8 breathing technique.',
      iconColor: Colors.blue,
      backgroundColor: AppColors.dailyTipBlue,
    ),
    DailyTip(
      icon: Icons.wb_sunny,
      title: 'Go Outside',
      description: 'Get 10 mins of sunlight.',
      iconColor: Colors.orange,
      backgroundColor: AppColors.dailyTipOrange,
    ),
    DailyTip(
      icon: Icons.music_note,
      title: 'Calm Audio',
      description: 'Listen to rain sounds.',
      iconColor: Colors.purple,
      backgroundColor: AppColors.dailyTipPurple,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPrefsService.getInstance();

    setState(() {
      _userName = prefs.getUserName(defaultValue: 'Alex');
      _userAvatarUrl = prefs.getUserAvatarUrl(
        defaultValue:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuBmmigwP6Wc1LPTtGqsJVJ-kB9-tUjRWKEdMxUGOcCqStYcsHXQaao94-cxgCvUKVgPeTUYJiub3aw9qD5gTZ-jn-v10TSSAbwYisOA5SPsH_adnb2yKp4P1BZeTYTxMmP201m6L657dwNp9bUYddJGtxB71VdtX0ZpX_VzSoeedlmfsw1dUBaRzlhIfEu9jFluvJDs_p537Owcf72Ep92_hb5P06r_0zXpl3zU986bwYpwLf3qabVssIkX1sno3dX9jtvmjNKUepF0',
      );
      _isLoading = false;
    });

    log('Loaded profile - Name: $_userName, Avatar: $_userAvatarUrl');
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, MMM d');
    return formatter.format(now);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 448),
            child: Stack(
              children: [
                // Main Scrollable Content
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getFormattedDate(),
                                  style: AppStyles.bodyMedium.copyWith(
                                    color: AppColors.textWhite60,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Hi, $_userName!',
                                  style: AppStyles.heading1.copyWith(
                                    fontSize: 32,
                                  ),
                                ),
                              ],
                            ),
                            Stack(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.whiteOverlay10,
                                      width: 2,
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(_userAvatarUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: -2,
                                  right: -2,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.backgroundDark,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      _moods[_selectedMoodIndex].icon,
                                      color: AppColors.textWhite,
                                      size: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Mood Check-in Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark,
                            borderRadius: AppStyles.radiusXLarge,
                            border: Border.all(color: AppColors.whiteOverlay5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'How are you feeling today?',
                                style: AppStyles.heading3.copyWith(
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: List.generate(
                                  _moods.length,
                                  (index) => GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedMoodIndex = index;
                                      });
                                    },
                                    child: Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: _selectedMoodIndex == index
                                            ? AppColors.primaryOverlay10
                                            : Colors.transparent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _moods[index].icon,
                                        size: 36,
                                        color: _selectedMoodIndex == index
                                            ? AppColors.primary
                                            : AppColors.textWhite80.withAlpha(
                                                90,
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Action Grid
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            // Chat Card
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 160,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: AppStyles.radiusXLarge,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryContent
                                              .withAlpha(25),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.chat_bubble,
                                          color: AppColors.primaryContent,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Chat with\nMindMate',
                                        style: AppStyles.bodyMedium.copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryContent,
                                          height: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'I\'m listening',
                                        style: AppStyles.bodySmall.copyWith(
                                          fontSize: 12,
                                          color: AppColors.primaryContent
                                              .withAlpha(205),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Voice Call Card
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  // Navigate to Call Screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CallScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 160,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceDark,
                                    borderRadius: AppStyles.radiusXLarge,
                                    border: Border.all(
                                      color: AppColors.whiteOverlay5,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryOverlay20,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.call,
                                          color: AppColors.primary,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Voice Call',
                                        style: AppStyles.bodyMedium.copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          height: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Let\'s talk it out',
                                        style: AppStyles.bodySmall.copyWith(
                                          fontSize: 12,
                                          color: AppColors.textWhite60,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Journal Entry Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark,
                            borderRadius: AppStyles.radiusXLarge,
                            border: Border.all(color: AppColors.whiteOverlay5),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Journal Entry',
                                        style: AppStyles.bodyMedium.copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Write about your day',
                                        style: AppStyles.bodySmall.copyWith(
                                          fontSize: 12,
                                          color: AppColors.textWhite60,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.whiteOverlay5,
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Open',
                                              style: AppStyles.bodySmall
                                                  .copyWith(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.arrow_forward,
                                              size: 14,
                                              color: AppColors.textWhite,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: 128,
                                height: 140,
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  borderRadius: AppStyles.radiusXLarge,
                                  image: const DecorationImage(
                                    image: NetworkImage(
                                      'https://lh3.googleusercontent.com/aida-public/AB6AXuCWkGb9SZMmEhCBe0Tz1Tz8iivxYMl_930XKHbZ27XXqgiUN0eKZLJbI6lVhVyKD4rV5oGbfeQehNiQOH7sogHis8BC2zjZ7ClXA8enBf2KaN7knQDeW_mDgX4gHxPJC1VgH4TsIU86QSV2fizt-O17BqY6s51rmdZNH-PhKRDKIJPsp12AbiNaLwGFpOtlUmfrk2AolchDqQpDzdx-KfETAh5ECS9TWgJKcOqXcWm11BWX8_2y9sORymJ2ecFuLEeeHnjfViTrO94Q',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Daily Tips Section
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Daily Tips',
                                    style: AppStyles.heading3.copyWith(
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    'View all',
                                    style: AppStyles.bodySmall.copyWith(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 160,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.only(right: 16),
                                itemCount: _dailyTips.length,
                                itemBuilder: (context, index) {
                                  final tip = _dailyTips[index];
                                  return Container(
                                    width: 160,
                                    margin: const EdgeInsets.only(right: 16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceDark,
                                      borderRadius: AppStyles.radiusXLarge,
                                      border: Border.all(
                                        color: AppColors.whiteOverlay5,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: tip.backgroundColor
                                                .withAlpha(77),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Icon(
                                            tip.icon,
                                            color: tip.iconColor,
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          tip.title,
                                          style: AppStyles.bodyMedium.copyWith(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          tip.description,
                                          style: AppStyles.bodySmall.copyWith(
                                            fontSize: 12,
                                            color: AppColors.textWhite60,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Floating Bottom Navigation
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDarkTransparent,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppColors.whiteOverlay10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.blackShadow,
                            blurRadius: 32,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _NavButton(
                            icon: Icons.home,
                            isSelected: _selectedNavIndex == 0,
                            onTap: () {
                              setState(() {
                                _selectedNavIndex = 0;
                              });
                            },
                          ),
                          const SizedBox(width: 40),
                          _NavButton(
                            icon: Icons.auto_stories,
                            isSelected: _selectedNavIndex == 1,
                            onTap: () {
                              setState(() {
                                _selectedNavIndex = 1;
                              });
                            },
                          ),
                          const SizedBox(width: 40),
                          _NavButton(
                            icon: Icons.person,
                            isSelected: _selectedNavIndex == 2,
                            onTap: () {
                              setState(() {
                                _selectedNavIndex = 2;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
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

class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryOverlay20 : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 24,
          color: isSelected ? AppColors.primary : AppColors.textWhite60,
        ),
      ),
    );
  }
}

// Data Models
class MoodOption {
  final IconData icon;
  final String label;

  MoodOption({required this.icon, required this.label});
}

class DailyTip {
  final IconData icon;
  final String title;
  final String description;
  final Color iconColor;
  final Color backgroundColor;

  DailyTip({
    required this.icon,
    required this.title,
    required this.description,
    required this.iconColor,
    required this.backgroundColor,
  });
}
