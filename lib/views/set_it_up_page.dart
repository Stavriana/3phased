import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eksaminiaia/controllers.dart/updateroom_controller.dart';
import 'package:eksaminiaia/repositories/updateroom_repository.dart';
import 'package:eksaminiaia/widgets/custom_counter_widget.dart';

class SetItUpPage extends StatelessWidget {
  final String roomCode;

  const SetItUpPage({super.key, required this.roomCode});

  @override
  Widget build(BuildContext context) {
    // Provide the required repository parameter
    final UpdateRoomController controller = Get.put(
      UpdateRoomController(repository: UpdateRoomRepository()),
    );

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Set Up Room: $roomCode'),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    CustomCounterWidget(
                      labelText: "NUMBER OF TEAMS",
                      minValue: 2,
                      maxValue: 6,
                      initialValue: controller.numOfTeams.value,
                      onValueChanged: (value) {
                        controller.numOfTeams.value = value;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomCounterWidget(
                      labelText: "NUMBER OF PLAYERS",
                      minValue: 4,
                      maxValue: 16,
                      initialValue: controller.numOfPlayers.value,
                      onValueChanged: (value) {
                        controller.numOfPlayers.value = value;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomCounterWidget(
                      labelText: "WORDS PER PLAYER",
                      minValue: 3,
                      maxValue: 10,
                      initialValue: controller.numOfWords.value,
                      onValueChanged: (value) {
                        controller.numOfWords.value = value;
                      },
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () async {
                        try {
                          await controller.updateRoom(roomCode);
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
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
