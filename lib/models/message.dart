import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String roomCode;
  final String sender;
  final String avatar;
  final String message;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.roomCode,
    required this.sender,
    required this.avatar,
    required this.message,
    required this.timestamp,
  });

  // Factory method to create a Message object from Firestore data
  factory Message.fromFirestore(String id, Map<String, dynamic> data) {
    return Message(
      id: id,
      roomCode: data['roomCode'] ?? '',
      sender: data['sender'] ?? '',
      avatar: data['avatar'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  // Convert a Message object to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'roomCode': roomCode,
      'sender': sender,
      'avatar': avatar,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
