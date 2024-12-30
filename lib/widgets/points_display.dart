import 'package:flutter/material.dart';
import 'package:eksaminiaia/models/room.dart';

class ScoreBox extends StatelessWidget {
  final Team team;

  // Add the `key` parameter and make the constructor `const`
  const ScoreBox({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(int.parse("0xFF${team.color}")),  // Assuming color is stored as hex string
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black, width: 2),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            team.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Points: ${team.points}',  // Display points
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
