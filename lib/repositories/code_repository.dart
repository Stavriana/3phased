import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class CodeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate a unique 4-character alphanumeric code
  String generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(4, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  // Create a room and save it to Firestore
  Future<String> createRoom() async {
    final String roomCode = generateRoomCode();

    try {
      await _firestore.collection('Rooms').doc(roomCode).set({
        'createdAt': FieldValue.serverTimestamp(),
      });
      return roomCode;
    } catch (e) {
      throw Exception('Failed to create room');
    }
  }
}
