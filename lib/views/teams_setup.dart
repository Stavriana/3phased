import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  final Map<int, String> teamNames = {};
  final Map<int, Color> teamColors = {};
  final Set<Color> selectedColors = {};
  final Map<int, TextEditingController> nameControllers = {};

  @override
  void initState() {
    super.initState();
    fetchGameDetails();
  }

  @override
  void dispose() {
    for (final controller in nameControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void fetchGameDetails() {
    Future.delayed(Duration.zero, () {
      setState(() {
        teamNames.clear();
        selectedColors.clear();
        nameControllers.clear();

        for (int i = 1; i <= _updateRoomController.numOfTeams.value; i++) {
          final teamKey = "Team $i";
          final team = _updateRoomController.ourteams[teamKey];

          final name = team?.name ?? "";
          teamNames[i] = name;
          nameControllers[i] = TextEditingController(text: name);

          final color = _hexToColor(team?.color ?? "#FFFFFF");
          teamColors[i] = color;
          if (color != const Color(0xFFFFFFFF)) {
            selectedColors.add(color);
          }

          if (team == null) {
            _updateRoomController.ourteams[teamKey] =
                Team(name: "", color: "#FFFFFF", players: []);
          }
        }
      });
    });
  }

  void handleNameChange(int teamNumber, String name) {
    setState(() {
      teamNames[teamNumber] = name;
      final teamKey = "Team $teamNumber";

      final existingTeam = _updateRoomController.ourteams[teamKey] ??
          Team(name: "", color: "#FFFFFF", players: []);
      _updateRoomController.ourteams[teamKey] = Team(
        name: name,
        color: existingTeam.color,
        players: existingTeam.players,
      );
    });
  }

  void handleColorChange(int teamNumber, Color color) {
    setState(() {
      final previousColor = teamColors[teamNumber];
      if (previousColor != null && previousColor != const Color(0xFFFFFFFF)) {
        selectedColors.remove(previousColor);
      }

      teamColors[teamNumber] = color;
      selectedColors.add(color);

      final teamKey = "Team $teamNumber";

      final existingTeam = _updateRoomController.ourteams[teamKey] ??
          Team(name: "", color: "#FFFFFF", players: []);
      _updateRoomController.ourteams[teamKey] = Team(
        name: existingTeam.name,
        color: _colorToHex(color),
        players: existingTeam.players,
      );
    });
  }

  Future<void> saveTeams() async {
    try {
      final updatedTeams = <String, Map<String, dynamic>>{};
      teamNames.forEach((teamNumber, name) {
        final teamKey = "Team $teamNumber";
        final colorHex = _colorToHex(teamColors[teamNumber] ?? const Color(0xFFFFFFFF));

        updatedTeams[teamKey] = {
          "name": name,
          "color": colorHex,
          "points": _updateRoomController.ourteams[teamKey]?.points ?? 0,
          "players": _updateRoomController.ourteams[teamKey]?.players
                  .map((player) => player.toJson())
                  .toList() ??
              [],
        };
      });

      log('Saving Teams: $updatedTeams', name: 'TeamsSet');

      await FirebaseFirestore.instance.collection('Rooms').doc(widget.roomCode).update({
        "numofteams": _updateRoomController.numOfTeams.value,
        "numofplayers": _updateRoomController.numOfPlayers.value,
        "numofwords": _updateRoomController.numOfWords.value,
        "ourteams": updatedTeams,
        "t1": _updateRoomController.t1.value,
        "t2": _updateRoomController.t2.value,
        "t3": _updateRoomController.t3.value,
      });

      Get.snackbar('Success', 'Teams have been saved successfully');
    } catch (e) {
      log('Error saving teams: $e', name: 'TeamsSet', level: 1000);
      Get.snackbar('Error', 'Failed to save teams: $e');
    }
  }

  String _colorToHex(Color color) {
    return '#${color.red.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${color.green.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${color.blue.toRadixString(16).padLeft(2, '0').toUpperCase()}';
  }

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
                        controller: nameControllers[i],
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
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
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
                                  if (!isColorTaken(color) || teamColors[i] == color) {
                                    handleColorChange(i, color);
                                  }
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 5),
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: teamColors[i] == color
                                        ? Border.all(width: 3, color: Colors.black)
                                        : null,
                                    boxShadow: isColorTaken(color) && teamColors[i] != color
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
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
      ),
    );
  }
}
