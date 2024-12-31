import 'package:flutter/material.dart';
//import 'package:eksaminiaia/models/room.dart';

class ScoreboardScreen extends StatelessWidget {
  final String roomCode;

  const ScoreboardScreen({super.key, required this.roomCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scoreboard'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Center(
              child: Column(
                children: [
                  const Text(
                    'SCOREBOARD',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Room Code: $roomCode',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            ScoreCard(
              positionImage: 'assets/images/firstplace.png',
              teamName: 'Team Alpha',
              points: 150,
              color: Colors.yellow,
            ),
            ScoreCard(
              positionImage: 'assets/images/secondplace.png',
              teamName: 'Team Beta',
              points: 120,
              color: Colors.grey,
            ),
            ScoreCard(
              positionImage: 'assets/images/thridplace.png',
              teamName: 'Team Gamma',
              points: 100,
              color: Colors.orange,
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ActionButton(
                  text: 'New Game',
                  color: Colors.green,
                  onPressed: () {
                    // Handle new game action
                  },
                ),
                ActionButton(
                  text: 'Exit',
                  color: Colors.red,
                  onPressed: () {
                    Navigator.pop(context); // Navigate back to the previous screen
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ScoreCard extends StatelessWidget {
  final String positionImage;
  final String teamName;
  final int points;
  final Color color;

  const ScoreCard({
    required this.positionImage,
    required this.teamName,
    required this.points,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                positionImage,
                width: 80,
                height: 80,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    teamName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '$points points',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const ActionButton({
    required this.text,
    required this.color,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );
  }
}
