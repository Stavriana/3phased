import 'package:flutter/material.dart';
import 'package:get/get.dart'; // For GetX state management
//import 'package:eksaminiaia/controllers/code_controller.dart'; // Import CodeController
import 'package:eksaminiaia/controllers.dart/code_controller.dart';
import 'points_page.dart'; // Import AvatarSelectionScreen
import 'package:cloud_firestore/cloud_firestore.dart';
import 'set_it_up_page.dart';

class CodeInputView extends StatefulWidget {
  const CodeInputView({super.key});

  @override
  State<CodeInputView> createState() => _CodeInputViewState();
}

class _CodeInputViewState extends State<CodeInputView> {
  final TextEditingController _codeController = TextEditingController();
  bool _isCodeValid = true;
  final CodeController _codeControllerInstance = Get.put(CodeController());

  // Function to check if the entered code exists in Firestore
  Future<bool> _checkCodeExists(String code) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('Rooms').doc(code).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Inside CodeInputView class
 void _joinGame(BuildContext context) async {
  final enteredCode = _codeController.text.trim().toUpperCase();

  // Ensure entered code is not empty or null
  if (enteredCode.isEmpty) {
    Get.snackbar(
      'Error',
      'Please enter a valid room code.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return;
  }

  // Check if the entered code exists in Firestore
  final codeExists = await _checkCodeExists(enteredCode);

  if (!mounted) return;

  if (codeExists) {
    // Pass enteredCode to AvatarSelectionScreen
    Get.to(() => AvatarSelectionScreen(code: enteredCode)); // Passing 'code' to AvatarSelectionScreen
  } else {
    // Show error message if the code does not exist
    Get.snackbar(
      'Error',
      'The room code is invalid or does not exist.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
 }


  // Function to create a new room and navigate to the setup page
  void _createRoom(BuildContext context) async {
    try {
      final String roomCode = await _codeControllerInstance.createRoom(); // Create a new room code

      // Ensure the widget is still mounted before using the BuildContext
      if (!mounted) return;

      // Use Get.to() for navigation
      Get.to(() => SetItUpPage(roomCode: roomCode)); // Navigate to setup page with room code
    } catch (e) {
      // Ensure the widget is still mounted before using the BuildContext
      if (!mounted) return;

      Get.snackbar(
        'Error',
        'Failed to create room. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join/Create Game')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            const Text(
              'JOIN A GAME',
              style: TextStyle(
                fontSize: 32,
                fontFamily: 'Rubik',
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Insert room code:',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Rubik',
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      color: _isCodeValid ? Colors.white : Colors.red.shade900,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        hintText: 'Enter code here...',
                        hintStyle: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                          fontFamily: 'Rubik',
                        ),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Rubik',
                      ),
                      onChanged: (_) {
                        setState(() {
                          _isCodeValid = true; // Reset validity on text change
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _joinGame(context), // Join game functionality
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Center(
              child: GestureDetector(
                onTap: () => _createRoom(context), // Create room functionality
                child: const CreateRoomButton(), // Button to create a room
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// CreateRoomButton widget for the "Create Room" button
class CreateRoomButton extends StatelessWidget {
  const CreateRoomButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/button_image.png', // Your button image asset here
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
    );
  }
}
