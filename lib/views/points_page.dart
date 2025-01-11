import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:eksaminiaia/models/room.dart';
import 'package:eksaminiaia/widgets/points_display.dart';
import 'package:eksaminiaia/views/code_input_view.dart'; // Import CodeInputView
import 'package:eksaminiaia/views/final.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'one_word.dart';
import 'pantomime.dart';

class PointsPage extends StatefulWidget {
  final String roomCode;
  final String currentTeam; // Add this parameter

  const PointsPage({super.key, required this.roomCode, required this.currentTeam});

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

          return Stack(
            children: [
              Column(
                children: [
                  // Header with score title
                  Container(
                    color: Colors.red,
                    width: double.infinity,
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        'SCORE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16), // Spacing below the header
                  // Team score display
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: sortedTeams.length,
                      itemBuilder: (context, index) {
                        Team team = sortedTeams[index].value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ScoreBox(team: team),
                        );
                      },
                    ),
                  ),
                  // NEXT Button
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          // Get the current authenticated user
                          final currentUser = FirebaseAuth.instance.currentUser;

                          if (currentUser == null) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'You must be signed in to perform this action.',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                            return;
                          }

                          // Fetch the room data from Firestore
                          final docSnapshot = await FirebaseFirestore.instance
                              .collection('Rooms')
                              .doc(widget.roomCode)
                              .get();

                          if (!docSnapshot.exists) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Room not found. Please try again.',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                            return;
                          }

                          final roomData = docSnapshot.data();
                          if (roomData == null || roomData['adminId'] == null) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Invalid room data. Please try again.',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                            return;
                          }

                          // Check if the current user is the admin
                          if (roomData['adminId'] != currentUser.uid) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Only the admin can proceed to the next screen.',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                            return;
                          }

                          // If the user is the admin, navigate to the appropriate screen based on "screen"
if (context.mounted) {
  final screen = roomData['screen'] as int? ?? 0;

  if (screen == 1) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantomimeScreen(
          roomCode: widget.roomCode,
          team: widget.currentTeam, // Replace with the appropriate team field
        ),
      ),
    );
  } else if (screen == 2) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OneWordScreen(
          roomCode: widget.roomCode,
          team: widget.currentTeam, // Replace with the appropriate team field
        ),
      ),
    );
  } else if (screen == 3) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ScoreboardScreen(
          roomCode: widget.roomCode,
          game: game,
        ),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invalid screen value: $screen'),
      ),
    );
  }
}

                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'An error occurred. Please try again later.',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.purple,
                        padding: EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 20,
                        ),
                        textStyle: TextStyle(fontSize: 20),
                      ),
                      child: Text('NEXT'),
                    ),
                  ),
                ],
              ),
              // Bottom-left house icon button
              Positioned(
                bottom: 16,
                left: 16,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CodeInputView()),
                    );
                  },
                  child: Image.asset(
                    'assets/images/house.png',
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
