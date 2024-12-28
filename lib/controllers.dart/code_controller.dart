import 'package:get/get.dart';
import 'package:eksaminiaia/repositories/code_repository.dart';

class CodeController extends GetxController {
  final CodeRepository codeRepository = CodeRepository();

  // Generate a new room code and save it to Firestore
  Future<String> createRoom() async {
    try {
      final String roomCode = await codeRepository.createRoom();
      return roomCode; // Return the generated room code
    } catch (e) {
      throw Exception('Failed to create room: ${e.toString()}');
    }
  }
}
