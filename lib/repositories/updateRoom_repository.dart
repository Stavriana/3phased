import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eksaminiaia/models/room.dart';

class UpdateRoomRepository {
  final FirebaseFirestore _firestore;

  UpdateRoomRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Save a new room
  Future<void> saveRoom(Game game) async {
    try {
      log('Saving Game to Firestore: ${game.toJson()}', name: 'UpdateRoomRepository');
      await _firestore.collection('Rooms').doc(game.id).set(game.toJson());
    } catch (e) {
      log('Error saving room: $e', name: 'UpdateRoomRepository', level: 1000);
      throw Exception('Failed to save room: $e');
    }
  }

  // Update an existing room
  Future<void> updateRoom(Game game) async {
    final roomDoc = _firestore.collection('Rooms').doc(game.id);

    try {
      if (!(await roomDoc.get()).exists) {
        log('Room with code ${game.id} does not exist.', name: 'UpdateRoomRepository');
        throw Exception('Room with code ${game.id} does not exist.');
      }

      log('Updating Game in Firestore: ${game.toJson()}', name: 'UpdateRoomRepository');
      await roomDoc.update(
        game.toJson()..addAll({"updatedAt": FieldValue.serverTimestamp()}),
      );
    } catch (e) {
      log('Error updating room: $e', name: 'UpdateRoomRepository', level: 1000);
      throw Exception('Failed to update room: $e');
    }
  }

  // Fetch a room by its code
  Future<Game> fetchRoom(String roomCode) async {
    try {
      final doc = await _firestore.collection('Rooms').doc(roomCode).get();

      if (!doc.exists) {
        log('Room with code $roomCode does not exist.', name: 'UpdateRoomRepository');
        throw Exception('Room with code $roomCode does not exist.');
      }

      log('Fetched Game from Firestore: ${doc.data()}', name: 'UpdateRoomRepository');
      return Game.fromFirestore(doc.id, doc.data()!);
    } catch (e) {
      log('Error fetching room: $e', name: 'UpdateRoomRepository', level: 1000);
      throw Exception('Failed to fetch room: $e');
    }
  }
}
