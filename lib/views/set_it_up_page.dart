import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eksaminiaia/controllers.dart/updateRoom_controller.dart';

class SetItUpPage extends StatelessWidget {
  final String roomCode; // Room code passed from CodeInputView

  const SetItUpPage({super.key, required this.roomCode});

  @override
  Widget build(BuildContext context) {
    final UpdateRoomController controller = Get.put(UpdateRoomController());
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Set Up Room: $roomCode'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                // Number of Players Input Field
                TextFormField(
                  controller: controller.numOfPlayersController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Number of Players',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the number of players';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Number of players must be a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Number of Teams Input Field
                TextFormField(
                  controller: controller.numOfTeamsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Number of Teams',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the number of teams';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Number of teams must be a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),

                // Submit Button
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final numOfPlayers =
                          int.parse(controller.numOfPlayersController.text.trim());
                      final numOfTeams =
                          int.parse(controller.numOfTeamsController.text.trim());

                      try {
                        await controller.updateRoom(roomCode, numOfPlayers, numOfTeams);
                        Get.snackbar(
                          'Success',
                          'Room updated successfully!',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      } catch (e) {
                        Get.snackbar(
                          'Error',
                          'Failed to update room. Please try again.',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
