import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eksaminiaia/controllers.dart/updateroom_controller.dart';
import 'package:eksaminiaia/repositories/updateroom_repository.dart';
import 'package:eksaminiaia/widgets/custom_counter_widget.dart';
import 'package:eksaminiaia/widgets/custom_slider_widget.dart';
//import 'package:eksaminiaia/views/teams_setup.dart'; // Ensure this import is correct
import 'teams_setup.dart';
class SetItUpPage extends StatelessWidget {
  final String roomCode;

  const SetItUpPage({super.key, required this.roomCode});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
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

                    // Number of Teams Counter
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

                    // Number of Players Counter
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

                    // Words Per Player Counter
                    CustomCounterWidget(
                      labelText: "WORDS PER PLAYER",
                      minValue: 3,
                      maxValue: 10,
                      initialValue: controller.numOfWords.value,
                      onValueChanged: (value) {
                        controller.numOfWords.value = value;
                      },
                    ),
                    const SizedBox(height: 30),

                    // Say What? Slider (T1)
                    CustomSliderWidget(
                      labelText: "SAY WHAT? (T1)",
                      minValue: 0,
                      maxValue: 160,
                      stepSize: 10,
                      initialValue: controller.t1.value.toDouble(),
                      onChanged: (value) {
                        controller.t1.value = value.toInt();
                      },
                    ),
                    const SizedBox(height: 20),

                    // Pantomime Slider (T2)
                    CustomSliderWidget(
                      labelText: "PANTOMIME (T2)",
                      minValue: 0,
                      maxValue: 160,
                      stepSize: 10,
                      initialValue: controller.t2.value.toDouble(),
                      onChanged: (value) {
                        controller.t2.value = value.toInt();
                      },
                    ),
                    const SizedBox(height: 20),

                    // One Word Slider (T3)
                    CustomSliderWidget(
                      labelText: "ONE WORD (T3)",
                      minValue: 0,
                      maxValue: 160,
                      stepSize: 10,
                      initialValue: controller.t3.value.toDouble(),
                      onChanged: (value) {
                        controller.t3.value = value.toInt();
                      },
                    ),
                    const SizedBox(height: 40),

                    // Submit Button Wrapped in GestureDetector for onTap
                    GestureDetector(
                      onTap: () async {
                        try {
                          // Save the room details
                          await controller.saveRoom(
                            roomCode: roomCode,
                            teams: controller.numOfTeams.value,
                            players: controller.numOfPlayers.value,
                            words: controller.numOfWords.value,
                            t1: controller.t1.value,
                            t2: controller.t2.value,
                            t3: controller.t3.value,
                          );

                          // Navigate to TeamsSetupPage
                          Get.to(() => TeamsSet(roomCode: roomCode));

                          Get.snackbar(
                            'Success',
                            'Room saved successfully!',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        } catch (e) {
                          Get.snackbar(
                            'Error',
                            'Failed to save room. Please try again.',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Submit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
