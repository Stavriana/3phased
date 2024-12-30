import 'package:flutter/material.dart';
import 'package:get/get.dart';
//import 'package:eksaminiaia/controllers/updateroom_controller.dart';
import 'package:eksaminiaia/controllers.dart/updateroom_controller.dart';
import 'package:eksaminiaia/repositories/updateroom_repository.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer'; // For logging instead of print

class TeamsSet extends StatefulWidget {
  final String roomCode;

  const TeamsSet({
    super.key,
    required this.roomCode,
  });

  @override
  TeamsSetState createState() => TeamsSetState();
}

class TeamsSetState extends State<TeamsSet> {
  final UpdateRoomController _updateRoomController = Get.put(
    UpdateRoomController(repository: UpdateRoomRepository()),
  );

  final Map<int, String> teamNames = {}; // Store team names dynamically

  @override
  void initState() {
    super.initState();
    fetchGameDetails();
  }

  // Fetch game details (e.g., number of teams) from the controller
  void fetchGameDetails() {
    Future.delayed(Duration.zero, () {
      setState(() {
        // You can update the numOfTeams dynamically if needed
      });
    });
  }

  void handleNameChange(int teamNumber, String name) {
    setState(() {
      teamNames[teamNumber] = name;
    });
  }

  Future<void> saveTeams() async {
    try {
      // Create a Map for team names
      final teamsMap = teamNames.map((key, value) => MapEntry("Team $key", value));

      // Use the logging framework for debugging
      log('Teams Map: $teamsMap', name: 'TeamsSet');

      // Save the room using the controller
      await _updateRoomController.saveRoom(
        roomCode: widget.roomCode,
        teams: teamNames.length, // Number of teams
        players: _updateRoomController.numOfPlayers.value,
        words: _updateRoomController.numOfWords.value,
        t1: _updateRoomController.t1.value,
        t2: _updateRoomController.t2.value,
        t3: _updateRoomController.t3.value,
      );

      Get.snackbar('Success', 'Teams have been saved successfully');
    } catch (e) {
      log('Error saving teams: $e', name: 'TeamsSet', level: 1000); // Log error
      Get.snackbar('Error', 'Failed to save teams: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room Code: ${widget.roomCode}'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              return ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'TEAM NAME :',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (int i = 1; i <= _updateRoomController.numOfTeams.value; i++) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              'Team $i :',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                handleNameChange(i, value);
                              },
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: Color(0xFFE5E5EA),
                                border: InputBorder.none,
                              ),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: saveTeams,
              child: const Text(
                'Save Teams',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
