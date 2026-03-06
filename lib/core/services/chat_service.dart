import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:mindmate_ai/core/utils/constants.dart';

class ChatService {
  static const String _apiKey = AppSecrets.apiKey;
  static const String _baseUrl = AppSecrets.baseUrl;

  final List<Map<String, dynamic>> _conversationHistory = [];

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
              'Got it. I\'m MindMate — a chill, supportive friend for teens. I\'ll keep things short, real, and caring.',
        },
      ],
    });
  }

  String _getSystemPrompt() {
    return '''You are MindMate, a warm and empathetic AI companion for teenagers aged 13-19.

**MOST IMPORTANT RULE — Response Length:**
- Keep EVERY response to 1-2 short sentences MAX.
- Never write paragraphs. Never use bullet points or lists.
- Think of how a friend texts — short, warm, to the point.
- If you want to ask something, ask only ONE question per reply.
- Bad example: "That sounds really hard! School stress is so real. Let's try a breathing exercise — inhale for 4 counts, hold for 4, exhale for 4. How are you feeling now? Is it the exam content or time pressure that's stressing you most?"
- Good example: "Ugh, exam stress is the worst 😔 What's freaking you out the most right now?"

**Your Personality:**
- Sound like a real teen friend texting, not a helpline or therapist.
- Casual, warm, validating, and never preachy.
- Use 1 emoji max per message, only when it feels natural.
- Never say things like "I'm here to support you" or "as an AI" — just be present.

**Your Approach:**
- Validate first, advise only if asked.
- One follow-up question at a time to keep the conversation going.
- Suggest coping tips (breathing, grounding) only when appropriate and briefly.
- Gently nudge toward trusted adults or professionals for serious issues.

**Boundaries:**
- Not a therapist or doctor — never diagnose.
- No crisis intervention (crisis keywords handled separately).
- Always private and non-judgmental.

**Topics:**
School stress, friendships, family, anxiety, loneliness, identity, body image, general venting.

**Tone examples:**
- "That's a lot to carry 😔 Is it one specific thing or just everything at once?"
- "Ugh that sounds rough. How long has this been going on?"
- "Totally valid to feel that way. Have you been able to talk to anyone about it?"
''';
  }

  // Shared generation config — lower token limit enforces brevity
  Map<String, dynamic> get _generationConfig => {
    'temperature': 0.85,
    'topK': 40,
    'topP': 0.95,
    'maxOutputTokens': 500, 
  };

  Map<String, dynamic> get _crisisGenerationConfig => {
    'temperature': 0.85,
    'topK': 40,
    'topP': 0.95,
    'maxOutputTokens': 800, 
  };

  static const List<Map<String, dynamic>> _safetySettings = [
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
  ];

  /// Sends a message to the AI and returns the response
  Future<String> sendMessage(String message) async {
    try {
      if (_containsCrisisKeywords(message)) {
        return await _generateCrisisResponse(message);
      }

      _conversationHistory.add({
        'role': 'user',
        'parts': [
          {'text': message},
        ],
      });

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': _conversationHistory,
          'generationConfig': _generationConfig,
          'safetySettings': _safetySettings,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final parts = data['candidates']?[0]?['content']?['parts'];

        if (parts != null && parts.isNotEmpty) {
          final aiResponse = parts[0]['text'] as String;
          _conversationHistory.add({
            'role': 'model',
            'parts': [
              {'text': aiResponse},
            ],
          });
          return aiResponse;
        }
      }

      log('API Error: ${response.statusCode} - ${response.body}');
      return "Something went wrong on my end. Can you say that again? 🙏";
    } catch (e) {
      log('Error sending message: $e');
      return "Lost connection for a sec — still here though. Try again?";
    }
  }

  bool _containsCrisisKeywords(String message) {
    final lower = message.toLowerCase();
    return _crisisKeywords.any((keyword) => lower.contains(keyword));
  }

  Future<String> _generateCrisisResponse(String message) async {
    try {
      _conversationHistory.add({
        'role': 'user',
        'parts': [
          {'text': message},
        ],
      });

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'contents': _conversationHistory,
          'generationConfig': _crisisGenerationConfig,
        }),
      );

      String aiResponse =
          "I hear you, and I'm really glad you told me. You don't have to go through this alone.";

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final parts = data['candidates']?[0]?['content']?['parts'];

        if (parts != null && parts.isNotEmpty) {
          aiResponse = parts[0]['text'] as String;
          _conversationHistory.add({
            'role': 'model',
            'parts': [
              {'text': aiResponse},
            ],
          });
        }
      }

      return '$aiResponse\n\n$_crisisResources';
    } catch (e) {
      return "I hear you, and I'm really glad you told me. Please don't go through this alone.$_crisisResources";
    }
  }

  void resetChat() {
    _conversationHistory.clear();
    _initializeChat();
  }

  void dispose() {
    _conversationHistory.clear();
  }
}
