import 'package:flutter/material.dart';
import 'package:eksaminiaia/models/room.dart';

class LastPlaces extends StatelessWidget {
  final Team team; // Pass the Team object dynamically

  const LastPlaces({
    super.key,
    required this.team,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 259,
      height: 166,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(
        children: [
          Positioned(
            left: 0.36,
            top: 0,
            child: Container(
              width: 258.63,
              height: 106.22,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D1D6),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            left: 0,
            top: 21,
            child: SizedBox(
              width: 258.63,
              height: 63.95,
              child: Text(
                team.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 29,
                  fontFamily: 'Koulen',
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.87,
                ),
              ),
            ),
          ),
          Positioned(
            left: 6,
            top: 106,
            child: SizedBox(
              width: 246,
              height: 60,
              child: Text(
                '${team.points} points',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 45,
                  fontFamily: 'Koulen',
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
