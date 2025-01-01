import 'package:flutter/material.dart';
import 'package:eksaminiaia/models/room.dart';

class TeamCard extends StatelessWidget {
  final Team team; // Team object
  final String trophyImage; // Trophy image
  final double height; // Height of the box
  final double width; // Width of the box
  final Color backgroundColor; // Background color of the box

  const TeamCard({
    super.key,
    required this.team,
    required this.trophyImage,
    required this.height,
    required this.width,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main box
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              team.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        // Trophy image positioned to the left of the box
        Positioned(
          left: -40, // Adjust this to move the image further to the left
          top: height * 0.2, // Center the image vertically relative to the box
          child: Container(
            width: 80, // Image width
            height: 80, // Image height
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(trophyImage),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        // Points positioned outside and centered at the bottom
        Positioned(
          bottom: -30, // Position the points below the box
          left: 0,
          right: 0,
          child: Text(
            '${team.points} POINTS',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
