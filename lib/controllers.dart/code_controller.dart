import 'dart:developer' as developer; // Import logging package
import 'package:get/get.dart';
import 'package:eksaminiaia/repositories/code_repository.dart';

class CodeController extends GetxController {
  final CodeRepository codeRepository = CodeRepository();

  // Generate a new room code and save it to Firestore
  Future<String> createRoom() async {
    try {
      final String roomCode = await codeRepository.createRoom();
      developer.log('Generated room code: $roomCode', name: 'CodeController'); // Use developer.log
      return roomCode; // Return the generated room code
    } catch (e) {
      developer.log('Error creating room: $e', name: 'CodeController', error: e); // Use developer.log for error
      throw Exception('Failed to create room: ${e.toString()}');
    }
  }
}
