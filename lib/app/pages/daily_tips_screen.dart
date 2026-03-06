import 'package:flutter/material.dart';
import '../../core/utils/colors.dart';
import '../../core/utils/styles.dart';

class DailyTipsScreen extends StatefulWidget {
  const DailyTipsScreen({super.key});

  @override
  State<DailyTipsScreen> createState() => _DailyTipsScreenState();
}

class _DailyTipsScreenState extends State<DailyTipsScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Breathing',
    'Movement',
    'Mindfulness',
    'Sleep',
  ];

  final List<TipItem> _tips = [
    TipItem(
      icon: Icons.self_improvement,
      title: 'Breathe In',
      description:
          'Try the 4-7-8 technique: inhale for 4 seconds, hold for 7, exhale for 8. '
          'This activates your parasympathetic nervous system and calms anxiety almost instantly.',
      category: 'Breathing',
      iconColor: Color(0xFF60A5FA),
      backgroundColor: Color(0xFF1e3a8a),
      readTime: '2 min',
    ),
    TipItem(
      icon: Icons.wb_sunny,
      title: 'Go Outside',
      description:
          'Just 10 minutes of natural sunlight boosts serotonin levels, improves mood, '
          'and helps regulate your sleep-wake cycle. Even on cloudy days, natural light helps.',
      category: 'Movement',
      iconColor: Color(0xFFFBBF24),
      backgroundColor: Color(0xFF7c2d12),
      readTime: '2 min',
    ),
    TipItem(
      icon: Icons.music_note,
      title: 'Calm Audio',
      description:
          'Listening to rain sounds or lo-fi music lowers cortisol levels. '
          'Try it for 15 minutes before bed to wind down — your brain associates these sounds with rest.',
      category: 'Sleep',
      iconColor: Color(0xFFC084FC),
      backgroundColor: Color(0xFF581c87),
      readTime: '3 min',
    ),
    TipItem(
      icon: Icons.water_drop,
      title: 'Stay Hydrated',
      description:
          'Even mild dehydration affects your mood and concentration. '
          'Drink a glass of water first thing in the morning before checking your phone — '
          'your brain is 75% water and needs it after 8 hours without.',
      category: 'Mindfulness',
      iconColor: Color(0xFF34D399),
      backgroundColor: Color(0xFF064e3b),
      readTime: '2 min',
    ),
    TipItem(
      icon: Icons.directions_walk,
      title: 'Take a Walk',
      description:
          'A 10-minute walk increases creative thinking by up to 81% according to Stanford research. '
          'No destination needed — just move. Walking also reduces rumination and anxious thoughts.',
      category: 'Movement',
      iconColor: Color(0xFFFBBF24),
      backgroundColor: Color(0xFF78350f),
      readTime: '3 min',
    ),
    TipItem(
      icon: Icons.phone_android_outlined,
      title: 'Phone Break',
      description:
          'Put your phone face-down for 30 minutes. Studies show that even the presence '
          'of your phone reduces your available cognitive capacity. Give your brain a break.',
      category: 'Mindfulness',
      iconColor: Color(0xFFF87171),
      backgroundColor: Color(0xFF7f1d1d),
      readTime: '2 min',
    ),
    TipItem(
      icon: Icons.nights_stay,
      title: 'Wind Down Ritual',
      description:
          'Start a 20-minute wind-down routine before bed: dim the lights, stop screens, '
          'and do something calm like reading or stretching. Consistency trains your brain to sleep faster.',
      category: 'Sleep',
      iconColor: Color(0xFF818CF8),
      backgroundColor: Color(0xFF1e1b4b),
      readTime: '3 min',
    ),
    TipItem(
      icon: Icons.favorite_border,
      title: 'Gratitude Pause',
      description:
          'Write down 3 things you\'re grateful for — they can be tiny, like a good cup of tea. '
          'Gratitude journaling rewires your brain toward positive pattern recognition over time.',
      category: 'Mindfulness',
      iconColor: Color(0xFFFB7185),
      backgroundColor: Color(0xFF881337),
      readTime: '2 min',
    ),
    TipItem(
      icon: Icons.sports_gymnastics,
      title: 'Stretch It Out',
      description:
          'Spend 5 minutes stretching your neck, shoulders, and back. '
          'Tension accumulates in these areas when you\'re stressed — releasing it physically '
          'signals safety to your nervous system.',
      category: 'Movement',
      iconColor: Color(0xFF6EE7B7),
      backgroundColor: Color(0xFF064e3b),
      readTime: '2 min',
    ),
    TipItem(
      icon: Icons.air,
      title: 'Box Breathing',
      description:
          'Inhale for 4 counts, hold for 4, exhale for 4, hold for 4. '
          'Repeat 4 times. Used by Navy SEALs to stay calm under pressure — '
          'it works by giving your mind a rhythmic focus.',
      category: 'Breathing',
      iconColor: Color(0xFF60A5FA),
      backgroundColor: Color(0xFF1e3a8a),
      readTime: '2 min',
    ),
  ];

  List<TipItem> get _filteredTips => _selectedCategory == 'All'
      ? _tips
      : _tips.where((t) => t.category == _selectedCategory).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.whiteOverlay5,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.textWhite,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Tips',
                        style: AppStyles.heading1.copyWith(fontSize: 26),
                      ),
                      Text(
                        '${_filteredTips.length} tips for you today',
                        style: AppStyles.bodySmall.copyWith(
                          color: AppColors.textWhite60,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Category filter chips ─────────────────────────────────
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _categories.length,
                itemBuilder: (_, i) {
                  final cat = _categories[i];
                  final isSelected = cat == _selectedCategory;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.whiteOverlay10,
                        ),
                      ),
                      child: Text(
                        cat,
                        style: AppStyles.bodySmall.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.primaryContent
                              : AppColors.textWhite60,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // ── Tips list ─────────────────────────────────────────────
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: ListView.separated(
                  key: ValueKey(_selectedCategory),
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  itemCount: _filteredTips.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, i) => _TipCard(tip: _filteredTips[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tip Card ──────────────────────────────────────────────────────────────────

class _TipCard extends StatefulWidget {
  final TipItem tip;
  const _TipCard({required this.tip});

  @override
  State<_TipCard> createState() => _TipCardState();
}

class _TipCardState extends State<_TipCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: AppStyles.radiusXLarge,
          border: Border.all(
            color: _expanded
                ? widget.tip.iconColor.withAlpha(80)
                : AppColors.whiteOverlay5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon box
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: widget.tip.backgroundColor.withAlpha(180),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    widget.tip.icon,
                    color: widget.tip.iconColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                // Title + meta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.tip.title,
                        style: AppStyles.bodyMedium.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: widget.tip.iconColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.tip.category,
                              style: AppStyles.bodySmall.copyWith(
                                fontSize: 11,
                                color: widget.tip.iconColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.schedule,
                            size: 11,
                            color: AppColors.textWhite60,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            widget.tip.readTime,
                            style: AppStyles.bodySmall.copyWith(
                              fontSize: 11,
                              color: AppColors.textWhite60,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Expand chevron
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textWhite60,
                    size: 22,
                  ),
                ),
              ],
            ),

            // Expandable description
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              sizeCurve: Curves.easeInOut,
              firstCurve: Curves.easeInOut,
              secondCurve: Curves.easeInOut,
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(color: AppColors.whiteOverlay5, height: 1),
                    const SizedBox(height: 14),
                    Text(
                      widget.tip.description,
                      style: AppStyles.bodySmall.copyWith(
                        fontSize: 14,
                        color: AppColors.textWhite80,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TipItem {
  final IconData icon;
  final String title;
  final String description;
  final String category;
  final Color iconColor;
  final Color backgroundColor;
  final String readTime;

  const TipItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.category,
    required this.iconColor,
    required this.backgroundColor,
    required this.readTime,
  });
}
