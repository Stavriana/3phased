import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eksaminiaia/models/message.dart';

class ChatroomScreen extends StatefulWidget {
  final String roomCode;
  final String playerName;
  final String avatarUrl;

  const ChatroomScreen({
    super.key,
    required this.roomCode,
    required this.playerName,
    required this.avatarUrl,
  });

  @override
  ChatroomScreenState createState() => ChatroomScreenState();
}

class ChatroomScreenState extends State<ChatroomScreen> {
  final TextEditingController messageController = TextEditingController();

  /// Fetch messages in real time
  Stream<List<Message>> fetchMessages() {
    return FirebaseFirestore.instance
        .collection('Messages')
        .where('roomCode', isEqualTo: widget.roomCode)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return Message.fromFirestore(doc.id, doc.data());
            }).toList());
  }

  /// Send a message
  Future<void> sendMessage() async {
    final messageText = messageController.text.trim();
    if (messageText.isEmpty) return;

    try {
      // Create a Message object
      final message = Message(
        id: '', // Firestore generates the ID
        roomCode: widget.roomCode,
        sender: widget.playerName,
        avatar: widget.avatarUrl,
        message: messageText,
        timestamp: DateTime.now(),
      );

      // Add the message to Firestore
      await FirebaseFirestore.instance.collection('Messages').add(message.toFirestore());

      if (!mounted) return; // Check if the widget is still mounted

      messageController.clear(); // Clear the text field
    } catch (e) {
      if (!mounted) return; // Check if the widget is still mounted

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send message')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatroom: ${widget.roomCode}'),
      ),
      body: Column(
        children: [
          // Message List
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: fetchMessages(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isSentByMe = message.sender == widget.playerName;

                    return Align(
                      alignment:
                          isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSentByMe ? Colors.blue[200] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isSentByMe) // Show sender's name only for received messages
                              Text(
                                message.sender,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            Text(
                              message.message,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Message Input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
