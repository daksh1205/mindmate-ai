import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/services/shared_preferences_service.dart';
import '../../core/utils/colors.dart';
import '../../core/utils/styles.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();

  int _selectedAvatarIndex = 0;
  int _selectedAgeRangeIndex = 1;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditMode = false;

  // Snapshot of saved values to restore on cancel
  String _savedName = '';
  int _savedAvatarIndex = 0;
  int _savedAgeRangeIndex = 1;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<_AvatarOption> _avatars = [
    _AvatarOption(
      name: 'Kitty',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuB1RgSZjiG97uvxCXxQuRAP5eHf7Bk5-hDomQKsDeQLpiMpgUHla9p4Tg8wzRbeKTxOnCc7o5r2ceSLfST-_wpba6D-CZ8hqTqlwFFbOkQguozWxVBfs-5B-yoXnj-6srrdmSzaeive2m7BPDbeaOHDuK_KYYtf-VpqI66KpOfheEYFAg0pmVo-2sNAK71-QwQj0aea8Wz9wVvqITI8ErqIQ9iClZrK04Kenu7QRqY-qir4Hj59cqP1QbVPrs3lJBvGnHi8T0U0eG8t',
    ),
    _AvatarOption(
      name: 'Bear',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAiWUNeZrJgQeg4y7ehVwmT-gYhr27-80l5VC5uk96OF-5wYq4ocxNrMCxmBl0WFvcOy9GZusS-uCHf2lEFag0MWABeI6tHLm7J6YY6O2eAVc13JFWBafGX7mrIHV7lvlyGR8y6_I2eX4Rf_nuJrLj7e9g1pWp37i4CA7FqnEk73TYUzF-WoDjIm4VZ6gCUOBLLppdS_dc1obGLHLNFMsTBzwpnHfbziPX52Y2L-hRLNKbjYRqN8ts0UunXycQ5Y9d36INH_ovYCY4T',
    ),
    _AvatarOption(
      name: 'Fox',
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuA82m0bzyiZkkj3MxqzVoCQj1SOoBIZg4kk2ohp8xoWrG2YLdgDlzSTd658mJR0-Pmdk8s0WckvImQI8Q-6hK5gEqyVWl8gYjrnP1Vx-n7ogAbjHD17fmLhDjiBx4HWzuP6975KVa8bepFsDBBrWra5BpbLMPWBalyhmmybc2kgo84n5H-2inQ070Iq2tLEcM3wSnRjd3Vg16_Pqbb-2_WoqsQMkc-vMJk3svIvLTHJ94Kd0hEg9Q438YvnD4kqQer0LABleJ5KrMF8',
    ),
  ];

  final List<_AgeRange> _ageRanges = [
    _AgeRange(range: '13-15', label: 'YOUNG TEEN'),
    _AgeRange(range: '16-17', label: 'MID TEEN'),
    _AgeRange(range: '18-19', label: 'YOUNG ADULT'),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPrefsService.getInstance();
    final name = prefs.getUserName(defaultValue: 'Alex');
    final avatarUrl = prefs.getUserAvatarUrl(defaultValue: '');
    final ageRange = prefs.getUserAgeRange(defaultValue: '16-17');

    final avatarIndex = _avatars.indexWhere((a) => a.imageUrl == avatarUrl);
    final ageIndex = _ageRanges.indexWhere((a) => a.range == ageRange);

    setState(() {
      _nameController.text = name;
      _selectedAvatarIndex = avatarIndex != -1 ? avatarIndex : 0;
      _selectedAgeRangeIndex = ageIndex != -1 ? ageIndex : 1;
      // Store snapshot
      _savedName = name;
      _savedAvatarIndex = _selectedAvatarIndex;
      _savedAgeRangeIndex = _selectedAgeRangeIndex;
      _isLoading = false;
    });

    log('Profile loaded — name: $name');
  }

  void _enterEditMode() {
    // Snapshot current saved state before editing
    _savedName = _nameController.text;
    _savedAvatarIndex = _selectedAvatarIndex;
    _savedAgeRangeIndex = _selectedAgeRangeIndex;
    setState(() => _isEditMode = true);
    _animController.forward();
  }

  void _cancelEdit() {
    // Restore snapshot
    setState(() {
      _nameController.text = _savedName;
      _selectedAvatarIndex = _savedAvatarIndex;
      _selectedAgeRangeIndex = _savedAgeRangeIndex;
      _isEditMode = false;
    });
    _animController.reverse();
    FocusScope.of(context).unfocus();
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showSnackBar('Please enter your name', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    final avatar = _avatars[_selectedAvatarIndex];
    final ageRange = _ageRanges[_selectedAgeRangeIndex];
    final prefs = await SharedPrefsService.getInstance();

    final success = await prefs.saveUserProfile(
      name: name,
      avatarName: avatar.name,
      avatarUrl: avatar.imageUrl,
      ageRange: ageRange.range,
      ageLabel: ageRange.label,
    );

    setState(() => _isSaving = false);

    if (success) {
      // Update snapshot to new saved values
      _savedName = name;
      _savedAvatarIndex = _selectedAvatarIndex;
      _savedAgeRangeIndex = _selectedAgeRangeIndex;
      setState(() => _isEditMode = false);
      _animController.reverse();
      FocusScope.of(context).unfocus();
      log('Profile saved — name: $name, avatar: ${avatar.name}');
      _showSnackBar('Profile updated');
    } else {
      _showSnackBar('Failed to save profile', isError: true);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: AppColors.textWhite,
              size: 18,
            ),
            const SizedBox(width: 12),
            Text(msg, style: AppStyles.bodySmall),
          ],
        ),
        backgroundColor: isError
            ? Colors.redAccent.withAlpha(220)
            : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return Column(
      children: [
        // ── Top bar ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Profile', style: AppStyles.heading3.copyWith(fontSize: 22)),

              // Replace the entire AnimatedSwitcher in the top bar with this:
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Cancel — slides in from left, invisible in view mode
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(-0.4, 0),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: _isEditMode
                        ? GestureDetector(
                            key: const ValueKey('cancel'),
                            onTap: _cancelEdit,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.whiteOverlay5,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Cancel',
                                style: AppStyles.bodySmall.copyWith(
                                  color: AppColors.textWhite60,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(key: ValueKey('cancel_hidden')),
                  ),

                  const SizedBox(width: 10),

                  // Edit ↔ Save — morphs in the same position
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.85,
                          end: 1.0,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: _isEditMode
                        ? GestureDetector(
                            key: const ValueKey('save'),
                            onTap: _isSaving ? null : _saveProfile,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: _isSaving
                                  ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primaryContent,
                                      ),
                                    )
                                  : Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: AppColors.primaryContent,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Save',
                                          style: AppStyles.bodySmall.copyWith(
                                            color: AppColors.primaryContent,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          )
                        : GestureDetector(
                            key: const ValueKey('edit'),
                            onTap: _enterEditMode,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryOverlay20,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.primary.withAlpha(80),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    size: 15,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Edit',
                                    style: AppStyles.bodySmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ── Scrollable content ─────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Avatar preview ───────────────────────────────────
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: _avatars[_selectedAvatarIndex].imageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Edit overlay badge
                      if (_isEditMode)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.backgroundDark,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 14,
                              color: AppColors.primaryContent,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    _nameController.text.isEmpty
                        ? 'Your Profile'
                        : _nameController.text,
                    style: AppStyles.heading3.copyWith(fontSize: 20),
                  ),
                ),
                Center(
                  child: Text(
                    _ageRanges[_selectedAgeRangeIndex].label,
                    style: AppStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Avatar picker (edit only) ────────────────────────
                FadeTransition(
                  opacity: _fadeAnim,
                  child: _isEditMode
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionLabel(label: 'PICK AN AVATAR'),
                            const SizedBox(height: 14),
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                itemCount: _avatars.length,
                                itemBuilder: (_, i) => _AvatarTile(
                                  avatar: _avatars[i],
                                  isSelected: i == _selectedAvatarIndex,
                                  onTap: () =>
                                      setState(() => _selectedAvatarIndex = i),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),

                // ── Name ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(label: 'NAME'),
                      const SizedBox(height: 12),
                      _isEditMode
                          ? TextField(
                              controller: _nameController,
                              onChanged: (_) => setState(() {}),
                              style: AppStyles.heading3.copyWith(fontSize: 18),
                              decoration: InputDecoration(
                                hintText: 'Your name or nickname...',
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
                                suffixIcon: const Icon(
                                  Icons.edit,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                            )
                          : _ReadOnlyField(
                              value: _nameController.text,
                              icon: Icons.person_outline,
                            ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── Age range ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _SectionLabel(label: 'AGE RANGE'),
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
                                color: AppColors.primary.withAlpha(180),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _isEditMode
                          ? Row(
                              children: List.generate(_ageRanges.length, (i) {
                                return Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      right: i < _ageRanges.length - 1 ? 12 : 0,
                                    ),
                                    child: _AgeRangeButton(
                                      ageRange: _ageRanges[i],
                                      isSelected: i == _selectedAgeRangeIndex,
                                      onTap: () => setState(
                                        () => _selectedAgeRangeIndex = i,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            )
                          : _ReadOnlyField(
                              value:
                                  '${_ageRanges[_selectedAgeRangeIndex].range} · ${_ageRanges[_selectedAgeRangeIndex].label}',
                              icon: Icons.cake_outlined,
                            ),
                      if (_isEditMode) ...[
                        const SizedBox(height: 10),
                        Text(
                          'We use this to curate the right advice for your age group.',
                          style: AppStyles.bodySmall.copyWith(
                            color: AppColors.textWhite60,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Read-only field ───────────────────────────────────────────────────────────

class _ReadOnlyField extends StatelessWidget {
  final String value;
  final IconData icon;

  const _ReadOnlyField({required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: AppStyles.radiusMedium,
        border: Border.all(color: AppColors.whiteOverlay5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textWhite60),
          const SizedBox(width: 12),
          Text(
            value,
            style: AppStyles.bodyMedium.copyWith(
              fontSize: 16,
              color: AppColors.textWhite,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        label,
        style: AppStyles.bodySmall.copyWith(
          fontSize: 12,
          color: AppColors.textWhite70,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _AvatarTile extends StatelessWidget {
  final _AvatarOption avatar;
  final bool isSelected;
  final VoidCallback onTap;

  const _AvatarTile({
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
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceDark,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: avatar.imageUrl,
                        fit: BoxFit.cover,
                      ),
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
            const SizedBox(height: 10),
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

class _AgeRangeButton extends StatelessWidget {
  final _AgeRange ageRange;
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
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.whiteOverlay5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              ageRange.range,
              style: AppStyles.heading1.copyWith(
                fontSize: 28,
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
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
                color: isSelected
                    ? AppColors.primaryContent.withAlpha(170)
                    : AppColors.textWhite60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Models ────────────────────────────────────────────────────────────────────

class _AvatarOption {
  final String name;
  final String imageUrl;
  _AvatarOption({required this.name, required this.imageUrl});
}

class _AgeRange {
  final String range;
  final String label;
  _AgeRange({required this.range, required this.label});
}
