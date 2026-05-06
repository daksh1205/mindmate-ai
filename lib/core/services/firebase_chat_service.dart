import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../app/pages/chat_screen.dart';

class FirebaseChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _conversationId;

  String? get conversationId => _conversationId;

  String? get _uid => _auth.currentUser?.uid;

  /// Call this when the chat screen opens to create a new conversation doc.
  Future<void> startConversation() async {
    if (_uid == null) return;

    final docRef = await _db.collection('conversations').add({
      'userId': _uid,
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': '',
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    _conversationId = docRef.id;
  }

  Future<void> saveMessage(ChatMessage message) async {
    if (_uid == null || _conversationId == null) return;

    // Add to messages subcollection
    await _db
        .collection('conversations')
        .doc(_conversationId)
        .collection('messages')
        .add({
          'text': message.text,
          'isUser': message.isUser,
          'timestamp': Timestamp.fromDate(message.timestamp),
        });

    // Update the parent doc's lastMessage + lastUpdated
    await _db.collection('conversations').doc(_conversationId).update({
      'lastMessage': message.text,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  /// Optional: call on back press to mark the conversation as ended.
  Future<void> endConversation() async {
    if (_uid == null || _conversationId == null) return;

    await _db.collection('conversations').doc(_conversationId).update({
      'endedAt': FieldValue.serverTimestamp(),
    });

    _conversationId = null;
  }

  /// Fetch all past conversations for the current user (for a history screen).
  Stream<QuerySnapshot> getUserConversations() {
    if (_uid == null) return const Stream.empty();

    return _db
        .collection('conversations')
        .where('userId', isEqualTo: _uid)
        .orderBy('lastUpdated', descending: true)
        .snapshots();
  }

  /// Fetch all messages for a given conversation ID (for replaying a past chat).
  Stream<QuerySnapshot> getMessages(String conversationId) {
    return _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
