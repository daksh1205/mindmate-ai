import 'package:flutter/material.dart';
import '../../core/services/call_service.dart';
import '../../core/utils/colors.dart';
import '../../core/utils/styles.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen>
    with SingleTickerProviderStateMixin {
  final CallService _callService = CallService();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleStartCall() async {
    if (_callService.callState.value != CallState.idle) return;

    // Show phone number input dialog
    final phoneNumber = await _showPhoneNumberDialog();

    if (phoneNumber == null || phoneNumber.isEmpty) {
      return; // User cancelled
    }

    // Start the call with phone number
    final success = await _callService.startCall(phoneNumber: phoneNumber);

    if (!success && mounted) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to connect. Please try again.',
            style: AppStyles.bodyMedium,
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<String?> _showPhoneNumberDialog() async {
    final TextEditingController phoneController = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter Phone Number',
                style: AppStyles.heading3.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // Country code
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDarkButton,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '+91',
                      style: AppStyles.bodyMedium.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Phone number input
                  Expanded(
                    child: TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      autofocus: true,
                      style: AppStyles.bodyMedium.copyWith(
                        fontSize: 16,
                        color: AppColors.textWhite,
                      ),
                      decoration: InputDecoration(
                        hintText: '1234567890',
                        hintStyle: AppStyles.bodyMedium.copyWith(
                          fontSize: 16,
                          color: AppColors.textGray400,
                        ),
                        filled: true,
                        fillColor: AppColors.surfaceDarkButton,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, null),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.surfaceDarkButton,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppStyles.bodyMedium.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textWhite80,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final phone = phoneController.text.trim();
                        if (phone.isNotEmpty) {
                          Navigator.pop(context, '+91$phone');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Call',
                        style: AppStyles.bodyMedium.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryContent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Stack(
          children: [
            // Subtle Background Glow
            Positioned(
              top: -100,
              left: 0,
              right: 0,
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.5,
                    colors: [AppColors.primaryOverlay5, Colors.transparent],
                  ),
                ),
              ),
            ),
            // Main Content
            Column(
              children: [
                // Header
                _buildHeader(),
                // Main Content Area
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        // Avatar & Greeting Section
                        _buildAvatarSection(),
                        const SizedBox(height: 60),
                        // Call Button with Ripples
                        _buildCallButton(),
                        const SizedBox(height: 60),
                        // Bottom Instructions
                        _buildInstructions(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceDarkButton,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.textWhite,
                size: 24,
              ),
            ),
          ),
          // Title (centered)
          Expanded(
            child: Text(
              'Ready to talk?',
              textAlign: TextAlign.center,
              style: AppStyles.heading3.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ),
          // Spacer for optical centering
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        // Avatar with online indicator
        Stack(
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.whiteOverlay20, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(77),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCeWca4T8M4LvClInwfBfQk_q57Re3t1Cw1CH3BJgGKgjjFr4ZdjAFf6GTWd7RUbdP3LKHRKmuaNB1VAJS5gnZ_4kDmVYSlDryrRASvA2n-3u_l2PJF8mfnukmnMtq13PNFM09A5cupJ74_B_MmdRyyZytuywzEySGYbHvOUp55VZ_zW71SHMkdp0ftuBufWvYfjvbnP6CldzZL0xXCve9RjzzOGjeW4-RTgU4fWaL4JZKxlXsKqmzsF0mD113Sd-wrVxXMkfHauEHl',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.backgroundDark, width: 4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Text content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              Text(
                "It's okay to just vent.",
                textAlign: TextAlign.center,
                style: AppStyles.heading1.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'MindMate is online and ready.',
                textAlign: TextAlign.center,
                style: AppStyles.bodyMedium.copyWith(
                  fontSize: 14,
                  color: AppColors.textGray400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCallButton() {
    return ValueListenableBuilder<CallState>(
      valueListenable: _callService.callState,
      builder: (context, callState, child) {
        String buttonText = 'START';
        bool isInteractive = true;

        switch (callState) {
          case CallState.connecting:
            buttonText = 'CONNECTING...';
            isInteractive = false;
            break;
          case CallState.connected:
            buttonText = 'CALLING';
            isInteractive = false;
            break;
          case CallState.idle:
          case CallState.disconnected:
          case CallState.error:
            buttonText = 'START';
            isInteractive = true;
            break;
        }

        return SizedBox(
          height: 320,
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Animated ripple effects
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // First ripple wave
                        _buildRipple(
                          scale: 1.0 + (_animation.value * 1.2),
                          opacity: 1.0 - _animation.value,
                        ),
                        // Second ripple wave (delayed)
                        _buildRipple(
                          scale:
                              1.0 +
                              ((_animation.value - 0.3).clamp(0.0, 1.0) * 1.2),
                          opacity: _animation.value < 0.3
                              ? 0.0
                              : 1.0 - (_animation.value - 0.3) / 0.7,
                        ),
                      ],
                    );
                  },
                ),
                // Static outer ripple ring
                Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryOverlay10,
                      width: 1,
                    ),
                    color: AppColors.primaryOverlay5,
                  ),
                ),
                // Static middle ripple ring
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryOverlay20,
                      width: 1,
                    ),
                    color: AppColors.primaryOverlay10,
                  ),
                ),
                // Main call button
                GestureDetector(
                  onTap: isInteractive ? _handleStartCall : null,
                  child: Container(
                    width: 144,
                    height: 144,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryShadow,
                          blurRadius: 40,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.call,
                          size: 48,
                          color: AppColors.primaryContent,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          buttonText,
                          style: AppStyles.bodySmall.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                            color: AppColors.primaryContent.withAlpha(204),
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
      },
    );
  }

  Widget _buildRipple({required double scale, required double opacity}) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 144,
        height: 144,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary.withAlpha((opacity * 40).toInt()),
            width: 2,
          ),
          color: AppColors.primary.withAlpha((opacity * 25).toInt()),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          // Main instruction text
          Text(
            "I'm listening. Whenever you're ready, tap to begin.",
            textAlign: TextAlign.center,
            style: AppStyles.bodyMedium.copyWith(
              fontSize: 16,
              color: AppColors.textWhite80,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          // Tip text
          Text(
            'Tip: Headphones are recommended for privacy.',
            textAlign: TextAlign.center,
            style: AppStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textGray400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
