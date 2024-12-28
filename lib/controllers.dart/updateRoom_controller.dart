import 'package:get/get.dart';
import 'package:eksaminiaia/models/room.dart';
import 'package:eksaminiaia/repositories/updateroom_repository.dart';

class UpdateRoomController extends GetxController {
  final UpdateRoomRepository repository;

  UpdateRoomController({required this.repository});

  // Reactive variables for room settings
  var numOfTeams = 2.obs;
  var numOfPlayers = 4.obs;
  var numOfWords = 3.obs;

  // Save a new room
  Future<void> saveRoom({
    required String roomCode,
    required int teams,
    required int players,
    required int words,
    required int t1,
    required int t2,
    required int t3,
  }) async {
    try {
      final game = Game(
        id: roomCode,
        numofteams: teams,
        numofplayers: players,
        numofwords: words,
        t1: t1,
        t2: t2,
        t3: t3,
      );
      await repository.saveRoom(game);
    } catch (e) {
      throw Exception('Failed to save room: $e');
    }
  }

  // Update an existing room
  Future<void> updateRoom(String roomCode) async {
    try {
      await repository.updateRoom(
        roomCode,
        numOfPlayers.value,
        numOfTeams.value,
        numOfWords.value,
      );
    } catch (e) {
      throw Exception('Failed to update room: $e');
    }
  }
}
