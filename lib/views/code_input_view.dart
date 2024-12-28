import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:eksaminiaia/controllers/code_controller.dart';
import 'package:eksaminiaia/views/set_it_up_page.dart'; // Import SetItUpPage
import 'package:eksaminiaia/controllers.dart/code_controller.dart';

class CodeInputView extends StatelessWidget {
  const CodeInputView({super.key});

  @override
  Widget build(BuildContext context) {
    final CodeController controller = Get.put(CodeController());

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Room'),
        ),
        body: Center(
          child: GestureDetector(
            onTap: () async {
              try {
                // Create a room (without numOfPlayers or numOfTeams yet)
                final String roomCode = await controller.createRoom();

                // Navigate to the next page to set up players and teams
                Get.to(() => SetItUpPage(roomCode: roomCode));
              } catch (e) {
                Get.snackbar(
                  'Error',
                  e.toString(), // Fixed here
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/button_image.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Positioned(
                    top: 55,
                    child: Text(
                      'CREATE\nROOM',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Rubik',
                        height: 1.2,
                      ),
                    ),
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
