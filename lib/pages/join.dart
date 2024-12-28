import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:eksaminiaia/models/room.dart';
import 'package:eksaminiaia/join_controller.dart';

class RoomInputPage extends StatelessWidget {
  const RoomInputPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(JoinController()); // Initialize the controller
    final formKey = GlobalKey<FormState>(); // Form key for validation

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Room Input'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  // Room Number Input Field
                  TextFormField(
                    controller: controller.numofplayers,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Room Number',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a room number';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Room number must be a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // Number of Teams Input Field
                  TextFormField(
                    controller: controller.numofteams,
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

                  // Save Button
                  ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        // Create Game model instance
                        final game = Game(
                          numofplayers: int.parse(controller.numofplayers.text.trim()),
                          numofteams:
                              int.parse(controller.numofteams.text.trim()),
                        );

                        // Pass Game model to the controller
                        controller.createRoom(game);

                        // Show success notification
                        Get.snackbar(
                          'Success',
                          'Room created successfully!',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    },
                    child: const Text('Create Room'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
