import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:eksaminiaia/models/room.dart';
import 'package:eksaminiaia/widgets/points_display.dart';

class PointsPage extends StatefulWidget {
  final String roomCode;

  const PointsPage({super.key, required this.roomCode});

  @override
  PointsPageState createState() => PointsPageState();
}

class PointsPageState extends State<PointsPage> {
  late Future<Game?> gameData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    gameData = fetchGameData(widget.roomCode);
  }

  Future<Game?> fetchGameData(String roomCode) async {
    try {
      log('Fetching room data for code: $roomCode');

      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('Rooms')
          .doc(roomCode)
          .get();

      if (!docSnapshot.exists) {
        log('Room not found for code: $roomCode');
        return null;
      }

      final data = docSnapshot.data();
      if (data == null) {
        log('No data found for room: $roomCode');
        return null;
      }

      return Game.fromFirestore(docSnapshot.id, data as Map<String, dynamic>);
    } catch (e) {
      log('Error fetching room data: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Points Page'),
        backgroundColor: Colors.red,
      ),
      body: FutureBuilder<Game?>(
        future: gameData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.data == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Room not found. Please check the code.',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          Game game = snapshot.data!;
          Map<String, Team> teams = game.ourteams;

          // Sort teams by points in descending order
          List<MapEntry<String, Team>> sortedTeams = teams.entries.toList()
            ..sort((a, b) => b.value.points.compareTo(a.value.points));

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SCOREBOARD',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 20),
                // Make the list of teams scrollable
                Expanded(
                  child: ListView.builder(
                    itemCount: sortedTeams.length,
                    itemBuilder: (context, index) {
                      String teamKey = sortedTeams[index].key;
                      Team team = sortedTeams[index].value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: ScoreBox(team: team),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Replace with your next navigation
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.purple,
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    textStyle: TextStyle(fontSize: 20),
                  ),
                  child: Text('NEXT'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
