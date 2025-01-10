import 'package:get/get.dart';
import 'package:eksaminiaia/models/room.dart';
import 'package:eksaminiaia/repositories/updateroom_repository.dart';
import 'dart:developer';
//import 'package:firebase_auth/firebase_auth.dart';

class UpdateRoomController extends GetxController {
  final UpdateRoomRepository repository;

  UpdateRoomController({required this.repository});
  
  // Reactive variables
  var adminId = ''.obs; // Add adminId as a rvariableeactive 
  var numOfTeams = 2.obs;
  var numOfPlayers = 4.obs;
  var numOfWords = 3.obs;
  var t1 = 0.obs; // SAY WHAT?
  var t2 = 0.obs; // PANTOMIME
  var t3 = 0.obs; // ONE WORD
  var ourteams = <String, Team>{}.obs;
  
  void updateGame(Game game) {
    numOfTeams.value = game.numofteams;
    numOfPlayers.value = game.numofplayers;
    numOfWords.value = game.numofwords;
    t1.value = game.t1;
    t2.value = game.t2;
    t3.value = game.t3;
    ourteams.clear();
    ourteams.addAll(game.ourteams);
  }

  // Save room
  Future<void> saveRoom({
    required String roomCode,
    required int teams,
    required int players,
    required int words,
    required int t1,
    required int t2,
    required int t3,
    required String admin,
  }) async {
    try {
      log('Preparing to save room. Our Teams: ${ourteams.toString()}', name: 'UpdateRoomController');

      final game = Game(
        id: roomCode,
        numofteams: teams,
        numofplayers: players,
        numofwords: words,
        t1: t1,
        t2: t2,
        t3: t3,
        ourteams: Map<String, Team>.from(ourteams),
        adminId: admin, // Pass adminId
      );

      await repository.saveRoom(game);

      log('Room saved successfully.', name: 'UpdateRoomController');
    } catch (e) {
      log('Error saving room: $e', name: 'UpdateRoomController', level: 1000);
      throw Exception('Failed to save room: $e');
    }
  }

  // Update room
  Future<void> updateRoom({
    required String roomCode,
    required int teams,
    required int players,
    required int words,
    required int t1,
    required int t2,
    required int t3,
    required String admin, // Add admin as a required parameter
  }) async {
    try {
      log('Preparing to update room. Our Teams: ${ourteams.toString()}', name: 'UpdateRoomController');

      final game = Game(
        id: roomCode,
        numofteams: teams,
        numofplayers: players,
        numofwords: words,
        t1: t1,
        t2: t2,
        t3: t3,
        ourteams: Map<String, Team>.from(ourteams),
        adminId: admin, // Pass adminId here as well
      );

      await repository.updateRoom(game);

      log('Room updated successfully.', name: 'UpdateRoomController');
    } catch (e) {
      log('Error updating room: $e', name: 'UpdateRoomController', level: 1000);
      throw Exception('Failed to update room: $e');
    }
  }

  // Fetch room data
  Future<void> fetchRoom(String roomCode) async {
    try {
      log('Fetching room data for code: $roomCode', name: 'UpdateRoomController');

      final game = await repository.fetchRoom(roomCode);

      numOfTeams.value = game.numofteams;
      numOfPlayers.value = game.numofplayers;
      numOfWords.value = game.numofwords;
      t1.value = game.t1;
      t2.value = game.t2;
      t3.value = game.t3;
      ourteams.value = game.ourteams;

      log('Room data fetched successfully. Our Teams: ${ourteams.toString()}', name: 'UpdateRoomController');
    } catch (e) {
      log('Error fetching room data: $e', name: 'UpdateRoomController', level: 1000);
      throw Exception('Failed to fetch room data: $e');
    }
  }
}
