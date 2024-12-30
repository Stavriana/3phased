import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer'; // For logging
//import 'package:eksaminiaia/controllers/updateroom_controller.dart';
import 'package:eksaminiaia/controllers.dart/updateroom_controller.dart';
import 'package:eksaminiaia/repositories/updateroom_repository.dart';
import 'package:eksaminiaia/models/room.dart';

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
  final Map<int, Color> teamColors = {}; // Store team colors dynamically
  final Set<Color> selectedColors = {}; // Track selected colors
  final Map<int, TextEditingController> nameControllers = {}; // Controllers for team names

  @override
  void initState() {
    super.initState();
    fetchGameDetails();
  }

  @override
  void dispose() {
    // Dispose of all TextEditingControllers
    for (final controller in nameControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Fetch game details and populate local data
  void fetchGameDetails() {
    Future.delayed(Duration.zero, () {
      setState(() {
        teamNames.clear();
        selectedColors.clear();
        nameControllers.clear();

        for (int i = 1; i <= _updateRoomController.numOfTeams.value; i++) {
          final teamKey = "Team $i";
          final team = _updateRoomController.ourteams[teamKey];

          // Populate `teamNames` and initialize TextEditingControllers
          final name = team?.name ?? "";
          teamNames[i] = name;

          // Only initialize controller if it doesn't already exist
          nameControllers[i] = TextEditingController(text: name);

          // Populate `teamColors`
          final color = _hexToColor(team?.color ?? "#FFFFFF");
          teamColors[i] = color;
          if (color != Color(0xFFFFFFFF)) {
            selectedColors.add(color);
          }

          // Ensure `ourteams` has a default entry for each team
          if (team == null) {
            _updateRoomController.ourteams[teamKey] =
                Team(name: "", color: "#FFFFFF", players: []);
          }
        }
      });
    });
  }

  // Update team name in both local and controller data
  void handleNameChange(int teamNumber, String name) {
    setState(() {
      teamNames[teamNumber] = name;
      final teamKey = "Team $teamNumber";

      // Update the team in the controller's `ourteams`
      final existingTeam = _updateRoomController.ourteams[teamKey] ??
          Team(name: "", color: "#FFFFFF", players: []);
      _updateRoomController.ourteams[teamKey] = Team(
        name: name,
        color: existingTeam.color,
        players: existingTeam.players,
      );
    });
  }

  // Update team color in both local and controller data
  void handleColorChange(int teamNumber, Color color) {
    setState(() {
      final previousColor = teamColors[teamNumber];
      if (previousColor != null && previousColor != Color(0xFFFFFFFF)) {
        selectedColors.remove(previousColor); // Remove previously selected color
      }

      teamColors[teamNumber] = color;
      selectedColors.add(color); // Add the new color

      final teamKey = "Team $teamNumber";

      // Update the team in the controller's `ourteams`
      final existingTeam = _updateRoomController.ourteams[teamKey] ??
          Team(name: "", color: "#FFFFFF", players: []);
      _updateRoomController.ourteams[teamKey] = Team(
        name: existingTeam.name,
        color: _colorToHex(color), // Use _colorToHex here
        players: existingTeam.players,
      );
    });
  }

  // Save teams data to Firestore
  Future<void> saveTeams() async {
    try {
      // Log current teams for debugging
      log('Saving Teams: ${_updateRoomController.ourteams}', name: 'TeamsSet');

      // Save the room using the controller
      await _updateRoomController.saveRoom(
        roomCode: widget.roomCode,
        teams: _updateRoomController.numOfTeams.value,
        players: _updateRoomController.numOfPlayers.value,
        words: _updateRoomController.numOfWords.value,
        t1: _updateRoomController.t1.value,
        t2: _updateRoomController.t2.value,
        t3: _updateRoomController.t3.value,
      );

      Get.snackbar('Success', 'Teams have been saved successfully');
    } catch (e) {
      log('Error saving teams: $e', name: 'TeamsSet', level: 1000);
      Get.snackbar('Error', 'Failed to save teams: $e');
    }
  }

  // Convert Color to Hex String
  // Convert Color to Hex String
   String _colorToHex(Color color) {
    return '#${color.r.toInt().toRadixString(16).padLeft(2, '0')}'
         '${color.g.toInt().toRadixString(16).padLeft(2, '0')}'
         '${color.b.toInt().toRadixString(16).padLeft(2, '0')}';
  }



  // Convert Hex String to Color
  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  bool isColorTaken(Color color) {
    return selectedColors.contains(color);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room Code: ${widget.roomCode}'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'TEAM NAME:',
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
                        'Team $i:',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: nameControllers[i], // Use persistent controller
                        onChanged: (value) => handleNameChange(i, value),
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'TEAM COLOR:',
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
                        'Team $i:',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (Color color in [
                          Colors.pink,
                          Colors.yellow,
                          Colors.blue,
                          Colors.orange,
                          Colors.green,
                          Colors.red
                        ])
                          GestureDetector(
                            onTap: () {
                              if (!isColorTaken(color) ||
                                  teamColors[i] == color) {
                                handleColorChange(i, color);
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: teamColors[i] == color
                                    ? Border.all(width: 4, color: Colors.black)
                                    : null,
                                boxShadow: isColorTaken(color) &&
                                        teamColors[i] != color
                                    ? [
                                        const BoxShadow(
                                          color: Colors.grey,
                                          blurRadius: 2,
                                        )
                                      ]
                                    : null,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: saveTeams, // Ensure this references the correct method
                child: const Text(
                  'Save Teams',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
