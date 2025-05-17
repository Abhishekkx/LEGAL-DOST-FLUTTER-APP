import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:legal_dost/services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:developer' as developer;

class ChatScreen extends StatefulWidget {
  final String recipientUid;
  final String recipientName;

  const ChatScreen({super.key, required this.recipientUid, required this.recipientName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final ScrollController _scrollController = ScrollController();
  bool _isFirstMessageSent = false;

  String get _currentUserUid => _authService.getCurrentUserUid() ?? '';

  @override
  void initState() {
    super.initState();
    _checkChatExists();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getChatId() {
    List<String> ids = [_currentUserUid, widget.recipientUid];
    ids.sort();
    return ids.join('_');
  }

  Future<void> _checkChatExists() async {
    try {
      final chatId = _getChatId();
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      setState(() {
        _isFirstMessageSent = chatDoc.exists;
      });
    } catch (e) {
      developer.log('Error checking if chat exists: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    final message = _messageController.text;
    final chatId = _getChatId();

    try {
      if (!_isFirstMessageSent) {
        await _firestore.collection('chats').doc(chatId).set({
          'participants': [_currentUserUid, widget.recipientUid],
          'lastMessage': message,
          'timestamp': FieldValue.serverTimestamp(),
        });
        setState(() {
          _isFirstMessageSent = true;
        });
        developer.log('Chat document created for first time, chatId: $chatId');
      } else {
        await _firestore.collection('chats').doc(chatId).update({
          'lastMessage': message,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      await _firestore.collection('chats').doc(chatId).collection('messages').add({
        'senderId': _currentUserUid,
        'receiverId': widget.recipientUid,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      _messageController.clear();
      developer.log('Message added successfully for chatId: $chatId');
    } catch (e) {
      developer.log('Error sending message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final chatId = _getChatId();

    return Scaffold(
      appBar: AppBar(
        title: Text('${localizations.chatWith} ${widget.recipientName}'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isFirstMessageSent
                ? StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, messageSnapshot) {
                if (messageSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (messageSnapshot.hasError) {
                  developer.log('Stream error: ${messageSnapshot.error}');
                  return Center(child: Text('Error: ${messageSnapshot.error}'));
                }

                final messages = messageSnapshot.data?.docs ?? [];
                developer.log('Received ${messages.length} messages for chatId: $chatId');

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });

                return messages.isEmpty
                    ? Center(child: Text(localizations.noMessages ?? 'No messages yet'))
                    : ListView.builder(
                  controller: _scrollController,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index].data() as Map<String, dynamic>;
                    final isSentByMe = messageData['senderId'] == _currentUserUid;
                    return Align(
                      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSentByMe ? Colors.teal[100] : Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          messageData['message'] ?? '',
                          style: TextStyle(color: isSentByMe ? Colors.teal[900] : Colors.black87),
                        ),
                      ),
                    );
                  },
                );
              },
            )
                : Center(
              child: Text(localizations.startConversation ?? 'Send a message to start the conversation'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: localizations.typeMessage,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.teal),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}