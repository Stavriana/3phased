import 'package:flutter/material.dart';
import 'package:eksaminiaia/models/room.dart';

class LastPlaces extends StatelessWidget {
  final Team team; // Pass the Team object dynamically
  final double width; // Pass the width dynamically to fit 3 widgets in a row

  const LastPlaces({
    super.key,
    required this.team,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main Box
        Container(
          width: width,
          height: 70,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          decoration: BoxDecoration(
            color: const Color(0xFFD1D1D6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              team.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
               
                fontWeight: FontWeight.bold,
                letterSpacing: 0.87,
              ),
            ),
          ),
        ),
        // Text outside at the bottom
        Positioned(
          bottom: -30, // Adjust distance from the bottom of the box
          left: 0,
          right: 0,
          child: Text(
            '${team.points} points',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              //fontFamily: 'Koulen',
              fontWeight: FontWeight.bold,
              //letterSpacing: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
