import 'package:flutter/material.dart';
import 'package:eksaminiaia/models/room.dart';

class TeamCard extends StatelessWidget {
  final Team team; // Team object
  final String trophyImage; // Trophy image
  final double width; // Width of the box
  final double height; // Height of the box
  final Color backgroundColor; // Background color of the box

  const TeamCard({
    super.key,
    required this.team,
    required this.trophyImage,
    this.width = double.infinity,
    this.height = 100,
    this.backgroundColor = Colors.purple,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Trophy image
          Image.asset(
            trophyImage,
            width: 50,
            height: 50,
          ),
          const SizedBox(width: 16),
          // Team name and points
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${team.points} POINTS',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
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
