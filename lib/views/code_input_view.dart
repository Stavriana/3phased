import 'package:flutter/material.dart';
import 'package:get/get.dart'; // For GetX state management
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eksaminiaia/views/avatar_setup.dart';
import 'set_it_up_page.dart'; // Import SetItUpPage for room creation

class CodeInputView extends StatefulWidget {
  const CodeInputView({super.key});

  @override
  State<CodeInputView> createState() => _CodeInputViewState();
}

class _CodeInputViewState extends State<CodeInputView> {
  final TextEditingController _codeController = TextEditingController();
  bool _isCodeValid = true;

  /// Function to check if the entered code exists in Firestore
  Future<bool> _checkCodeExists(String code) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('Rooms').doc(code).get();
      return doc.exists;
    } catch (e) {
      debugPrint('Error checking code existence: $e');
      return false;
    }
  }

  /// Function to fetch room data from Firestore
  Future<Map<String, dynamic>?> _fetchRoomData(String roomCode) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance.collection('Rooms').doc(roomCode).get();

      if (!docSnapshot.exists) {
        debugPrint('Room not found for code: $roomCode');
        return null;
      }

      final data = docSnapshot.data();
      debugPrint('Room data: $data'); // Log the raw data for debugging
      return data;
    } catch (e) {
      debugPrint('Error fetching room data: $e');
      return null;
    }
  }

  /// Function to join a game room
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

    // Check if the room code exists
    final codeExists = await _checkCodeExists(enteredCode);

    if (!mounted) return;

    if (codeExists) {
      // Fetch room data before navigating
      final roomData = await _fetchRoomData(enteredCode);

      if (roomData != null) {
        // Navigate to PointsPage with the room code
        Get.to(() => AvatarSelectionScreen(roomCode: enteredCode));
      } else {
        Get.snackbar(
          'Error',
          'Failed to load room data.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar(
        'Error',
        'The room code is invalid or does not exist.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Function to create a new room
void _createRoom(BuildContext context) async {
  try {
    // Generate a random 4-character room code
    final roomCode = _generateRandomRoomCode();

    // Add the room to Firestore with default fields
    await FirebaseFirestore.instance.collection('Rooms').doc(roomCode).set({
      'ourteams': {}, // Initialize with an empty 'ourteams' field
      'words': [], // Initialize with an empty array for words
      'numofwords': 5, // Example: default number of words per player
    });

    if (!mounted) return;

    // Navigate to SetItUpPage with the room code
    Get.to(() => SetItUpPage(roomCode: roomCode));
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
      Iterable.generate(4, (_) => characters.codeUnitAt(
        DateTime.now().millisecondsSinceEpoch % characters.length,
      )),
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
                child: const CreateRoomButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// CreateRoomButton widget for the "Create Room" button
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
