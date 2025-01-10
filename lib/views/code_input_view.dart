import 'package:eksaminiaia/views/team_words.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // For GetX state management
import 'package:cloud_firestore/cloud_firestore.dart';
import 'set_it_up_page.dart'; // Import SetItUpPage for room creation
import 'package:firebase_auth/firebase_auth.dart';

class CodeInputView extends StatefulWidget {
  const CodeInputView({super.key});

  @override
  State<CodeInputView> createState() => _CodeInputViewState();
}

class _CodeInputViewState extends State<CodeInputView> {
  final TextEditingController _codeController = TextEditingController();
  bool _isCodeValid = true;

  /// Function to join a game
  void _joinGame(BuildContext context) async {
    final enteredCode = _codeController.text.trim().toUpperCase();

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

    try {
      // Fetch the Firestore document for the entered room code
      final docSnapshot = await FirebaseFirestore.instance
          .collection('Rooms')
          .doc(enteredCode)
          .get();

      // Check if the document exists
      if (!docSnapshot.exists) {
        Get.snackbar(
          'Error',
          'The room code is invalid or does not exist.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Retrieve the document data
      final roomData = docSnapshot.data();

      if (roomData == null) {
        Get.snackbar(
          'Error',
          'Failed to load room data.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Extract playersIn and numOfPlayers values
      final int playersIn = roomData['playersin'] ?? 0; // Default to 0 if not found
      final int numOfPlayers = roomData['numofplayers'] ?? 0; // Default to 0 if not found

      // Check if the room is full
      if (playersIn >= numOfPlayers) {
        Get.snackbar(
          'Room Full',
          'The room is already full. Please try another room.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      // If the room is not full, navigate to the next screen
      Get.to(() => TeamWordsScreen(roomCode: enteredCode));
    } catch (e) {
      // Handle errors and show an appropriate message
      Get.snackbar(
        'Error',
        'An error occurred while joining the room. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _createRoom(BuildContext context) async {
  try {
    // Fetch current user
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      debugPrint('No user is signed in!');
      Get.snackbar(
        'Sign-In Required',
        'You must sign in to create a room.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final userUid = currentUser.uid;
    debugPrint('Current User UID: $userUid');

    // Generate a random room code
    final roomCode = _generateRandomRoomCode();

    // Save room data to Firestore
    await FirebaseFirestore.instance.collection('Rooms').doc(roomCode).set({
      'adminId': userUid, // Pass the current user UID as adminId
      'id': roomCode,
      'ourteams': {}, // Initialize teams
      'words': [], // Initialize words
      'numofwords': 5, // Default number of words
      'numofplayers': 4, // Example default
      'numofteams': 2,  // Example default
    });

    // Debug log to verify
    final savedDoc = await FirebaseFirestore.instance.collection('Rooms').doc(roomCode).get();
    debugPrint('Room created successfully. adminId: ${savedDoc['adminId']}');

    // Navigate to SetItUpPage
    if (mounted) {
      Get.to(() => SetItUpPage(roomCode: roomCode));
    }
  } catch (e) {
    debugPrint('Error creating room: $e');
    Get.snackbar(
      'Error',
      'Failed to create room. Please try again later.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
 }


  /// Function to generate a random 4-character room code
  String _generateRandomRoomCode() {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return String.fromCharCodes(
      Iterable.generate(
        4,
        (_) => characters.codeUnitAt(
          DateTime.now().millisecondsSinceEpoch % characters.length,
        ),
      ),
    );
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
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Insert room code:',
              style: TextStyle(
                fontSize: 18,
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
                        ),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                      onChanged: (_) {
                        setState(() {
                          _isCodeValid = true;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _joinGame(context),
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
                onTap: () => _createRoom(context),
                child: const CreateRoomButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// CreateRoomButton widget
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
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
