import 'package:cloud_firestore/cloud_firestore.dart';

class CodeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Update room details in Firestore
  Future<void> updateRoom(String roomCode, int numOfPlayers, int numOfTeams) async {
    if (roomCode.isEmpty) {
      throw Exception('Room code cannot be empty');
    }
    if (numOfPlayers <= 0 || numOfTeams <= 0) {
      throw Exception('Number of players and teams must be greater than zero');
    }

    try {
      await _firestore.collection('Rooms').doc(roomCode).update({
        'numOfPlayers': numOfPlayers,
        'numOfTeams': numOfTeams,
      });
    } catch (e) {
      throw Exception('Failed to update room in Firestore: ${e.toString()}');
    }
  }
}
