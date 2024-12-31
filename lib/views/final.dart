import 'package:flutter/material.dart';
import 'package:eksaminiaia/models/room.dart';
import 'package:eksaminiaia/widgets/first_place.dart';
import 'package:eksaminiaia/widgets/last_places.dart';


class ScoreboardScreen extends StatelessWidget {
  final String roomCode;
  final Game game;

  const ScoreboardScreen({
    super.key,
    required this.roomCode,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    // Sort teams by points in descending order
    final sortedTeams = game.ourteams.values.toList()
      ..sort((a, b) => b.points.compareTo(a.points));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scoreboard'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Title and Room Code
            const Text(
              'SCOREBOARD',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Room Code: $roomCode',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 30),
            // Use TeamCard for 1st, 2nd, and 3rd places
            if (sortedTeams.isNotEmpty)
              TeamCard(
                team: sortedTeams[0],
                trophyImage: 'assets/images/firstplace.png',
                height: 120,
                backgroundColor: Colors.purple,
              ),
            if (sortedTeams.length > 1)
              TeamCard(
                team: sortedTeams[1],
                trophyImage: 'assets/images/secondplace.png',
                height: 110,
                backgroundColor: Colors.grey,
              ),
            if (sortedTeams.length > 2)
              TeamCard(
                team: sortedTeams[2],
                trophyImage: 'assets/images/thirdplace.png',
                height: 100,
                backgroundColor: Colors.orange,
              ),
            const SizedBox(height: 20),
            // Use LastPlaces for 4th, 5th, and 6th places
            if (sortedTeams.length > 3)
              Column(
                children: sortedTeams.sublist(3).map((team) {
                  return LastPlaces(team: team);
                }).toList(),
              ),
            const SizedBox(height: 20),
            // New Game and Exit Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    // Handle new game action
                  },
                  child: const Text(
                    'New Game',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Exit action
                  },
                  child: const Text(
                    'Exit',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
