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
  Future<void> updateRoom(Game game) async {
    final roomDoc = _firestore.collection('Rooms').doc(game.id);

    try {
      if (!(await roomDoc.get()).exists) {
        throw Exception('Room with code ${game.id} does not exist.');
      }

      await roomDoc.update(game.toJson()..addAll({"updatedAt": FieldValue.serverTimestamp()}));
    } catch (e) {
      throw Exception('Failed to update room: $e');
    }
  }
}
