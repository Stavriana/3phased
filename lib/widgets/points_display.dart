import 'package:flutter/material.dart';
import 'package:eksaminiaia/models/room.dart';

class ScoreBox extends StatelessWidget {
  final Team team;

  const ScoreBox({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    // Calculate the box width based on points (example: 1 point = 10px width)
    double boxWidth = (team.points.toDouble() * 10).clamp(100.0, MediaQuery.of(context).size.width * 0.9);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Team name displayed at the top
        Text(
          team.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4), // Small spacing between name and box
        Container(
          width: boxWidth, // Dynamically adjust width based on points
          decoration: BoxDecoration(
            color: _parseColor(team.color), // Use parsed color
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black, width: 2),
          ),
          padding: const EdgeInsets.all(16),
          child: Text(
            'Points: ${team.points}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  // Updated color parsing function
  Color _parseColor(String? colorString) {
    if (colorString == null || colorString.trim().isEmpty) {
      debugPrint("Color string is null or empty. Using fallback color.");
      return const Color.fromARGB(255, 200, 158, 158); // Fallback color
    }

    try {
      colorString = colorString.trim();
      debugPrint("Parsing color: $colorString");

      // Convert #RRGGBB to Color.fromARGB format
      if (colorString.startsWith("#")) {
        final hexValue = int.parse(colorString.substring(1), radix: 16);
        final color = Color(0xFF000000 | hexValue);
        debugPrint("Converted color: ${color.toString()}");
        return color;
      }

      // Parse 0xFFRRGGBB normally
      if (colorString.startsWith("0xFF")) {
        final color = Color(int.parse(colorString));
        debugPrint("Parsed color: ${color.toString()}");
        return color;
      }

      throw FormatException("Invalid color format: $colorString");
    } catch (e) {
      debugPrint("Error parsing color: $colorString. Using fallback color. Error: $e");
      return const Color.fromARGB(255, 200, 158, 158); // Fallback color
    }
  }
}
