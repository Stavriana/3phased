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

  // Reactive variables for sliders (T1, T2, T3)
  var t1 = 0.obs; // SAY WHAT?
  var t2 = 0.obs; // PANTOMIME
  var t3 = 0.obs; // ONE WORD

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
        ourteams: {},
      );
      await repository.saveRoom(game);
    } catch (e) {
      throw Exception('Failed to save room: $e');
    }
  }

  // Update an existing room
  Future<void> updateRoom({
    required String roomCode,
    required int teams,
    required int players,
    required int words,
    required int t1,
    required int t2,
    required int t3,
    //required Map ourteams,
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
      await repository.updateRoom(game);
    } catch (e) {
      throw Exception('Failed to update room: $e');
    }
  }
}
