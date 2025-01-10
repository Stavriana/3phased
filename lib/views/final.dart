import 'package:flutter/material.dart';
import 'package:eksaminiaia/models/room.dart';
import 'package:eksaminiaia/widgets/first_place.dart';
import 'package:eksaminiaia/widgets/last_places.dart';
import 'package:eksaminiaia/views/code_input_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScoreboardScreen extends StatelessWidget {
  final String roomCode;
  final Game game;

  const ScoreboardScreen({
    super.key,
    required this.roomCode,
    required this.game,
  });

  Future<void> _clearChosenData() async {
    try {
      await FirebaseFirestore.instance
          .collection('Rooms')
          .doc(roomCode)
          .update({
        'chosen': FieldValue.delete(), // Clears the chosen field
      });
      debugPrint('Chosen data cleared successfully.');
    } catch (e) {
      debugPrint('Error clearing chosen data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Automatically clear chosen data when the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) => _clearChosenData());

    // Sort teams by points in descending order
    final sortedTeams = game.ourteams.values.toList()
      ..sort((a, b) => b.points.compareTo(a.points));

    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 60), // Margin at the top
          // Title and Room Code
          Container(
            width: screenWidth * 0.9,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1CA63E), // Green color (#1CA63E)
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'SCOREBOARD',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 50), // Space after title
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
                children: [
                  // Use TeamCard for 1st place
                  if (sortedTeams.isNotEmpty)
                    Center(
                      child: TeamCard(
                        team: sortedTeams[0],
                        trophyImage: 'assets/images/firstplace.png',
                        height: 110,
                        backgroundColor: Colors.purple,
                        width: screenWidth * 0.5, // Take 50% of screen width
                      ),
                    ),
                  const SizedBox(height: 50),
                  // Use TeamCard for 2nd and 3rd places side by side
                  if (sortedTeams.length > 1 && sortedTeams.length > 2)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TeamCard(
                          team: sortedTeams[1],
                          trophyImage: 'assets/images/secondplace.png',
                          height: 85,
                          backgroundColor: const Color(0xFFB69DF7),
                          width: screenWidth * 0.4, // Each card takes 40% of the screen width
                        ),
                        TeamCard(
                          team: sortedTeams[2],
                          trophyImage: 'assets/images/thridplace.png',
                          height: 85,
                          backgroundColor: const Color(0xFFB69DF7),
                          width: screenWidth * 0.4, // Each card takes 40% of the screen width
                        ),
                      ],
                    ),
                  const SizedBox(height: 150),
                  // Use LastPlaces for 4th and beyond
                  if (sortedTeams.length > 3)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Wrap(
                        spacing: 12.0, // Horizontal spacing between elements
                        runSpacing: 12.0, // Vertical spacing between rows
                        alignment: WrapAlignment.start, // Align items to the left
                        children: sortedTeams.sublist(3).map((team) {
                          return LastPlaces(
                            team: team,
                            width: screenWidth * 0.28, // Each card takes 28% of the screen width
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 20), // Add margin between LastPlaces and buttons
                ],
              ),
            ),
          ),
          // New Game and Exit Buttons at the bottom
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 60.0), // Margins for the buttons
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(175, 172, 76, 1),
                    minimumSize: Size(screenWidth * 0.6, 75), // Dynamic width, fixed height
                  ),
                  //child: GestureDetector(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CodeInputView()),
                    );
                  },
                  child: const Text(
                    'NEW GAME',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: Size(screenWidth * 0.3, 60), // Same height as the first button
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CodeInputView()),
                    );
                  },
                  child: const Text(
                    'EXIT',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

