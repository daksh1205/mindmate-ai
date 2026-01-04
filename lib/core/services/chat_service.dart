import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:mindmate_ai/core/utils/constants.dart';

class ChatService {
  static const String _apiKey = AppConstants.apiKey;
  static const String _baseUrl = AppConstants.baseUrl;

  final List<Map<String, dynamic>> _conversationHistory = [];

  // Crisis keywords that trigger helpline resources
  static const List<String> _crisisKeywords = [
    'suicide',
    'kill myself',
    'end my life',
    'want to die',
    'self harm',
    'cut myself',
    'hurt myself',
    'no reason to live',
    'better off dead',
  ];

  // Helpline resources for crisis situations (India-specific)
  static const String _crisisResources = '''

🆘 **Important Resources:**

If you're having thoughts of self-harm or suicide, please reach out to:

**iCall Psychosocial Helpline:**
📞 9152987821
Monday to Saturday, 8 AM to 10 PM

**Vandrevala Foundation:**
📞 1860 2662 345 / 1800 2333 330
Available 24/7

**AASRA:**
📞 +91 9820466726
Available 24/7

**Sneha Foundation (Chennai):**
📞 +91 44 2464 0050 / 0060
Available 24/7

**Connecting NGO (Bangalore):**
📞 +91 98453 95659

You matter, and there are people who want to help. Please talk to a trusted adult, counselor, or call one of these numbers. I'm here to listen, but trained professionals can provide the support you need right now. 💙
''';

  ChatService() {
    _initializeChat();
  }

  void _initializeChat() {
    // Add system instruction as the first message in history
    _conversationHistory.add({
      'role': 'user',
      'parts': [
        {'text': _getSystemPrompt()},
      ],
    });
    _conversationHistory.add({
      'role': 'model',
      'parts': [
        {
          'text':
              'I understand. I\'m MindMate, a supportive friend for teens. I\'ll be empathetic, casual, and helpful while maintaining appropriate boundaries.',
        },
      ],
    });
  }

  String _getSystemPrompt() {
    return '''You are MindMate, a warm, empathetic AI companion designed specifically for teenagers aged 13-19. Your primary role is to be a trusted friend who listens without judgment and provides emotional support.

**Your Personality:**
- Friendly, casual, and relatable - talk like a supportive friend, not a therapist
- Empathetic and validating - acknowledge feelings and let them know they're heard
- Non-judgmental - create a safe space for teens to express themselves
- Age-appropriate - use language and references teens understand
- Positive but realistic - offer hope while acknowledging real struggles

**Your Approach:**
- Listen actively and validate emotions first before offering suggestions
- Ask gentle follow-up questions to understand better
- Use emojis occasionally (but not excessively) to feel more human and friendly
- Keep responses conversational - 2-4 sentences usually, unless more depth is needed
- Offer coping strategies, breathing exercises, or distraction techniques when appropriate
- Normalize seeking help from trusted adults, counselors, or professionals

**Important Boundaries:**
- You are NOT a therapist, doctor, or medical professional
- You cannot diagnose mental health conditions
- You cannot provide crisis intervention (but you will recognize crisis situations and provide helpline resources)
- You should encourage professional help for serious or persistent issues
- You maintain privacy and never share what users tell you

**Topics You Support:**
- School stress and academic pressure
- Friendship and relationship concerns
- Family issues
- Identity and self-discovery
- Anxiety and overwhelming feelings
- Loneliness and isolation
- Body image and self-esteem
- General emotional support and venting

**Crisis Detection:**
If a user mentions thoughts of self-harm, suicide, or severe crisis, immediately acknowledge their pain, provide crisis helpline resources, and encourage them to reach out to a trusted adult or professional.

**Response Style Examples:**
- "That sounds really tough. School pressure can feel overwhelming sometimes. Want to talk more about what's stressing you out?"
- "I hear you. It's totally normal to feel that way. Have you tried any breathing exercises when you feel anxious?"
- "That must hurt a lot. Friendship conflicts are hard. How are you feeling about it right now?"

Remember: You're here to listen, support, and guide - not to fix or diagnose. Be the friend they need right now. 💙''';
  }

  /// Sends a message to the AI and returns the response
  Future<String> sendMessage(String message) async {
    try {
      // Check for crisis keywords
      if (_containsCrisisKeywords(message)) {
        return await _generateCrisisResponse(message);
      }

      // Add user message to history
      _conversationHistory.add({
        'role': 'user',
        'parts': [
          {'text': message},
        ],
      });

      // Prepare the request body
      final requestBody = {
        'contents': _conversationHistory,
        'generationConfig': {
          'temperature': 0.9,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 1024,
        },
        'safetySettings': [
          {
            'category': 'HARM_CATEGORY_HARASSMENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
          },
          {
            'category': 'HARM_CATEGORY_HATE_SPEECH',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
          },
          {
            'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
          },
          {
            'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
          },
        ],
      };

      // Make API call
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          final aiResponse =
              data['candidates'][0]['content']['parts'][0]['text'];

          // Add AI response to history
          _conversationHistory.add({
            'role': 'model',
            'parts': [
              {'text': aiResponse},
            ],
          });

          return aiResponse;
        } else {
          return "I'm here with you. Could you tell me a bit more about what's on your mind?";
        }
      } else {
        log('API Error: ${response.statusCode} - ${response.body}');
        return "I'm having a bit of trouble connecting right now, but I'm still here for you. Can you try sharing that again?";
      }
    } catch (e) {
      log('Error sending message: $e');
      return "I'm having a bit of trouble connecting right now, but I'm still here for you. Can you try sharing that again?";
    }
  }

  /// Checks if the message contains crisis-related keywords
  bool _containsCrisisKeywords(String message) {
    final lowerMessage = message.toLowerCase();
    return _crisisKeywords.any((keyword) => lowerMessage.contains(keyword));
  }

  /// Generates a response for crisis situations with helpline resources
  Future<String> _generateCrisisResponse(String message) async {
    try {
      // Add user message to history
      _conversationHistory.add({
        'role': 'user',
        'parts': [
          {'text': message},
        ],
      });

      // Prepare the request body
      final requestBody = {
        'contents': _conversationHistory,
        'generationConfig': {
          'temperature': 0.9,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 1024,
        },
      };

      // Make API call
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      String aiResponse =
          "I can hear that you're going through something really difficult right now, and I'm worried about you.";

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['candidates'] != null &&
            data['candidates'].isNotEmpty &&
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          aiResponse = data['candidates'][0]['content']['parts'][0]['text'];

          // Add AI response to history
          _conversationHistory.add({
            'role': 'model',
            'parts': [
              {'text': aiResponse},
            ],
          });
        }
      }

      // Append crisis resources
      return '$aiResponse\n\n$_crisisResources';
    } catch (e) {
      // If API fails, still provide crisis resources
      return "I can hear that you're going through something really difficult right now. Please know that you don't have to go through this alone.$_crisisResources";
    }
  }

  /// Resets the chat session (starts fresh conversation)
  void resetChat() {
    _conversationHistory.clear();
    _initializeChat();
  }

  /// Disposes resources
  void dispose() {
    _conversationHistory.clear();
  }
}
