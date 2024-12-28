import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eksaminiaia/models/room.dart';

class UpdateRoomRepository {
  final FirebaseFirestore _firestore;

  // Constructor allows Firestore injection for testing
  UpdateRoomRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Save a new room
  Future<void> saveRoom(Game game) async {
    try {
      await _firestore.collection('Rooms').doc(game.id).set(game.toJson());
    } catch (e) {
      throw Exception('Failed to save room: $e');
    }
  }

  // Update an existing room
  Future<void> updateRoom(String roomCode, int players, int teams, int words) async {
    final roomDoc = _firestore.collection('Rooms').doc(roomCode);

    try {
      if (!(await roomDoc.get()).exists) {
        throw Exception('Room with code $roomCode does not exist.');
      }

      await roomDoc.update({
        "numofplayers": players,
        "numofteams": teams,
        "numofwords": words,
        "updatedAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update room: $e');
    }
  }

  // Fetch a room by its ID
  Future<Game?> fetchRoom(String roomCode) async {
    try {
      final docSnapshot = await _firestore.collection('Rooms').doc(roomCode).get();

      if (!docSnapshot.exists) return null;

      final data = docSnapshot.data();
      if (data != null) {
        return Game.fromFirestore(roomCode, data);
      }
    } catch (e) {
      throw Exception('Failed to fetch room: $e');
    }
    return null;
  }
}
