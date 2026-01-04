import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:intl/intl.dart';
import '../../core/services/chat_service.dart';
import '../../core/utils/colors.dart';
import '../../core/utils/styles.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final ChatService _chatService = ChatService();

  bool _isTyping = false;
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _updateCurrentTime();
    _loadWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _chatService.dispose();
    super.dispose();
  }

  void _updateCurrentTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('h:mm a').format(now);
    });
  }

  Future<void> _loadWelcomeMessage() async {
    await Future.delayed(const Duration(milliseconds: 500));

    _addMessage(
      ChatMessage(
        text:
            "Hey! I'm MindMate, your supportive friend. 💙 I'm here whenever you need someone to talk to. How are you feeling today?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    // Add user message
    _addMessage(
      ChatMessage(text: userMessage, isUser: true, timestamp: DateTime.now()),
    );

    // Show typing indicator
    setState(() {
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      // Get AI response
      final aiResponse = await _chatService.sendMessage(userMessage);

      // Hide typing indicator
      setState(() {
        _isTyping = false;
      });

      // Add AI response
      _addMessage(
        ChatMessage(text: aiResponse, isUser: false, timestamp: DateTime.now()),
      );
    } catch (e) {
      // Hide typing indicator
      setState(() {
        _isTyping = false;
      });

      // Show error message
      _addMessage(
        ChatMessage(
          text:
              "I'm having a bit of trouble right now, but I'm still here for you. Can you try that again?",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    }
  }

  void _handleChipTap(String chipText) {
    // Extract the text without emoji
    String message = '';
    if (chipText.contains('vent')) {
      message = "I need to vent about something";
    } else if (chipText.contains('Breathing')) {
      message = "Can we do a breathing exercise?";
    } else if (chipText.contains('Distract')) {
      message = "I need a distraction right now";
    }

    if (message.isNotEmpty) {
      _messageController.text = message;
      _sendMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                itemCount: _messages.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildTimestamp();
                  }

                  if (index == _messages.length + 1) {
                    return _isTyping
                        ? _buildTypingIndicator()
                        : const SizedBox.shrink();
                  }

                  final message = _messages[index - 1];
                  return _buildMessageBubble(message);
                },
              ),
            ),
            _buildBottomSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withAlpha(95),
        border: Border(
          bottom: BorderSide(color: AppColors.whiteOverlay5, width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.textSlate400,
                size: 20,
              ),
            ),
          ),
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.whiteOverlay10, width: 2),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuCml4UemnH0gKKZkgMDLB-dOKrzYjuQ0CzTOXaQ_R9TsksLL9kzGRohuV7wqNuIcXC5EZip21rBA2Ep4zS5g_OYKwsISKWEqZc424pohbEIud-cP16f_ogdmtB-wCZB0l2Dh6cMxglSitQO84Fa3HJ5vt0horTZyT-mIHqv3OCo11j5P5KizofiO3XP3h7l8CYEM2jGPMzCOdS6PAlwQ_AOtzrVPgW07Qk1xxLfiGuHq0yFK2g7DROznoDfMAKewr0DFakEoB9iBVB_',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.onlineIndicator,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.backgroundDark,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MindMate',
                  style: AppStyles.heading3.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Always here for you',
                  style: AppStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              // Show options menu
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.more_vert,
                color: AppColors.textSlate400,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestamp() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.whiteOverlay10,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Today, $_currentTime',
          style: AppStyles.bodySmall.copyWith(
            fontSize: 11,
            color: AppColors.textSlate500,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 12, bottom: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuB0gZpaa--YNIKxroQxl6hqhDioMgy7NThAKFZxlG4EU44aNUs6KR2fCex_pe-2uZ6xUmVaFYwnvpk_qdcn_0lVK30bCU0Utv7O7ktCk4glJuWWWkSwqNZ2NFJqvJI_tM-TNZdkFh40U5al-6nK15Tmd0XI9Gza2lWY3HcjIPS0TvH1AkHwO3VUkIm-_xjzWJwDgyrvoAKB-nl4iD5nWEwXx5MAb7EkWf4xyCdUrqjuW7uxZbFWEjb7TWkEkJJi7kgMbxghSADCLIUP',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: message.isUser ? AppColors.primary : AppColors.lavender,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isUser ? 20 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 20),
                ),
              ),
              child: message.isUser
                  ? Text(
                      message.text,
                      style: AppStyles.bodyMedium.copyWith(
                        fontSize: 15,
                        color: AppColors.primaryText,
                        height: 1.4,
                      ),
                    )
                  : MarkdownBody(
                      data: message.text,
                      styleSheet: MarkdownStyleSheet(
                        p: AppStyles.bodyMedium.copyWith(
                          fontSize: 15,
                          color: AppColors.lavenderText,
                          height: 1.4,
                        ),
                        strong: AppStyles.bodyMedium.copyWith(
                          fontSize: 15,
                          color: AppColors.lavenderText,
                          height: 1.4,
                          fontWeight: FontWeight.w700,
                        ),
                        em: AppStyles.bodyMedium.copyWith(
                          fontSize: 15,
                          color: AppColors.lavenderText,
                          height: 1.4,
                          fontStyle: FontStyle.italic,
                        ),
                        listBullet: AppStyles.bodyMedium.copyWith(
                          fontSize: 15,
                          color: AppColors.lavenderText,
                          height: 1.4,
                        ),
                        code: AppStyles.bodyMedium.copyWith(
                          fontSize: 14,
                          color: AppColors.lavenderText,
                          fontFamily: 'monospace',
                        ),
                        h1: AppStyles.bodyMedium.copyWith(
                          fontSize: 18,
                          color: AppColors.lavenderText,
                          fontWeight: FontWeight.w700,
                        ),
                        h2: AppStyles.bodyMedium.copyWith(
                          fontSize: 17,
                          color: AppColors.lavenderText,
                          fontWeight: FontWeight.w700,
                        ),
                        h3: AppStyles.bodyMedium.copyWith(
                          fontSize: 16,
                          color: AppColors.lavenderText,
                          fontWeight: FontWeight.w700,
                        ),
                        blockquote: AppStyles.bodyMedium.copyWith(
                          fontSize: 15,
                          color: AppColors.lavenderText.withAlpha(80),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      selectable: false,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Opacity(
            opacity: 0.5,
            child: Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 12, bottom: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDxaA8clGNJl1doVUuN08KR-14fuyBuOUuk-IzMmNoC2SbTKAROvfYgYuvzWsCMuxmhzwwpPE0X0ngmaE3p-yCr1PVsalUv5iyDOAu3IeqGMY7KPzBNFfa9pp6VcSj9ieHb1XK7UweG1H3lyrapfwO2FG4odqwYphgJ9QXrUdUMP-91QREokeRHam0-zzdXY0qj3oCEJ84LyiMAeP4lcCQa3TqAady_6Ul7K6zj3GBwX1CSGnnu6qR7U73SM_mpFjyvKQRT0RCPc-8M',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceDarkChat,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(color: AppColors.whiteOverlay5, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 6),
                _buildTypingDot(200),
                const SizedBox(width: 6),
                _buildTypingDot(400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return FutureBuilder(
          future: Future.delayed(Duration(milliseconds: delay)),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.textSlate500,
                  shape: BoxShape.circle,
                ),
              );
            }
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, -8 * (0.5 - (value - 0.5).abs()) * 2),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.textSlate500,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
              onEnd: () {
                if (mounted) {
                  setState(() {});
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(top: BorderSide(color: Colors.transparent, width: 0)),
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildChip('😤 Let\'s vent'),
                const SizedBox(width: 8),
                _buildChip('🌬️ Breathing exercise'),
                const SizedBox(width: 8),
                _buildChip('🎬 Distract me'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDarkChat,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: AppColors.whiteOverlay10,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16, right: 8),
                          child: Icon(
                            Icons.add_circle_outline,
                            color: AppColors.textSlate400,
                            size: 24,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          style: AppStyles.bodyMedium.copyWith(
                            fontSize: 16,
                            color: AppColors.textWhite,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            hintStyle: AppStyles.bodyMedium.copyWith(
                              fontSize: 16,
                              color: AppColors.textSlate400,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 14,
                            ),
                          ),
                          maxLines: null,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8, right: 16),
                          child: Icon(
                            Icons.mic_none,
                            color: AppColors.textSlate400,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryOverlay50,
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.send,
                    color: AppColors.primaryText,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label) {
    return GestureDetector(
      onTap: () => _handleChipTap(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceDarkChat,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.whiteOverlay10, width: 1),
        ),
        child: Text(
          label,
          style: AppStyles.bodySmall.copyWith(
            fontSize: 14,
            color: AppColors.textWhite,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
