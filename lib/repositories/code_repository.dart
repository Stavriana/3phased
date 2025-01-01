import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'dart:developer' as developer;

class CodeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random random = Random();
    return String.fromCharCodes(
      Iterable.generate(4, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  Future<String> createRoom() async {
    String roomCode;

    do {
      roomCode = generateRoomCode();
      developer.log('Generated room code: $roomCode', name: 'CodeRepository'); // Log generated code
      final doc = await _firestore.collection('Rooms').doc(roomCode).get();
      if (!doc.exists) break;
      developer.log('Room code already exists, regenerating...', name: 'CodeRepository'); // Log collision
    } while (true);

    try {
      await _firestore.collection('Rooms').doc(roomCode).set({
        'createdAt': FieldValue.serverTimestamp(),
      });
      developer.log('Room saved to Firestore with code: $roomCode', name: 'CodeRepository'); // Log success
      return roomCode;
    } catch (e) {
      developer.log('Error saving room to Firestore', name: 'CodeRepository', error: e); // Log error
      throw Exception('Failed to create room: $e');
    }
  }
}
