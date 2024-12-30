import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:eksaminiaia/models/room.dart';  // Ensure your models are properly imported
import 'package:eksaminiaia/widgets/points_display.dart';  // Import the file where your models are defined
//import 'package:eksaminiaia/models/room.dart';
class AvatarSelectionScreen extends StatefulWidget {
  final String code;  // Add a 'code' parameter to accept the room code

  const AvatarSelectionScreen({super.key, required this.code});

  @override
  AvatarSelectionScreenState createState() => AvatarSelectionScreenState();
}

class AvatarSelectionScreenState extends State<AvatarSelectionScreen> {
  late Future<Game> gameData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Use the 'code' passed through the constructor to fetch the game data
    gameData = fetchGameData(widget.code);
  }

  Future<Game> fetchGameData(String roomCode) async {
  try {
    // Fetch the game data from Firestore using the passed roomCode
    DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
        .collection('games')
        .doc(roomCode)  // Use the roomCode here
        .get();

    // Log the roomCode and document status
    //log('Fetching game data for room: $roomCode');
    //log('Document exists: ${docSnapshot.exists}');

    if (!docSnapshot.exists) {
      throw Exception('Room not found');
    }

    final data = docSnapshot.data();
    if (data == null) {
      throw Exception('No data found');
    }

    // Convert the Firestore document into a Game model
    return Game.fromFirestore(docSnapshot.id, data as Map<String, dynamic>);
  } catch (e) {
    // Log the error and rethrow
    //log('Error fetching game data: $e');
    throw Exception('Error fetching game data: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Score Page'),
        backgroundColor: Colors.red,
      ),
      body: FutureBuilder<Game>(
        future: gameData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: Text('No data found.'));
          }

          Game game = snapshot.data!;
          int numofteams = game.numofteams;  // Number of teams
          Map<String, Team> teams = game.ourteams; // The teams

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SCORE',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 20),
                // Display team widgets dynamically based on numofteams
                Column(
                  children: List.generate(numofteams, (index) {
                    String teamKey = teams.keys.elementAt(index); // Get team key
                    Team team = teams[teamKey]!;  // Get team by key
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ScoreBox(team: team),
                    );
                  }),
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () {
                    // Handle NEXT button press
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, 
                    backgroundColor: Colors.purple,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    textStyle: TextStyle(fontSize: 20),
                  ),
                  child: Text('NEXT'),  // 'child' should be last
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
