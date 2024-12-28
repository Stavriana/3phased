import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eksaminiaia/repositories/updateRoom_repository.dart';

class UpdateRoomController extends GetxController {
  final CodeRepository codeRepository = CodeRepository();

  final TextEditingController numOfPlayersController = TextEditingController();
  final TextEditingController numOfTeamsController = TextEditingController();

  Future<void> updateRoom(String roomCode, int numOfPlayers, int numOfTeams) async {
    try {
      await codeRepository.updateRoom(roomCode, numOfPlayers, numOfTeams);
      Get.snackbar(
        'Success',
        'Room updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update room: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    numOfPlayersController.dispose();
    numOfTeamsController.dispose();
    super.onClose();
  }
}
