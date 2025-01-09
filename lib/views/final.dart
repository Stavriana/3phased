import 'package:flutter/material.dart';
import 'package:eksaminiaia/models/room.dart';
import 'package:eksaminiaia/widgets/first_place.dart';
import 'package:eksaminiaia/widgets/last_places.dart';
import 'package:eksaminiaia/views/code_input_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:just_audio/just_audio.dart';

class ScoreboardScreen extends StatefulWidget {
  final String roomCode;
  final Game game;

  const ScoreboardScreen({
    super.key,
    required this.roomCode,
    required this.game,
  });

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playSound(); // Play the sound as the first action
  }

  Future<String> _fetchSoundUrl() async {
    final doc = await FirebaseFirestore.instance
        .collection('sounds')
        .doc('finalSound')
        .get();

    if (doc.exists && doc.data() != null) {
      return doc['url'];
    } else {
      throw Exception('Sound not found in Firestore');
    }
  }

  void _playSound() async {
    try {
      String soundUrl = await _fetchSoundUrl();
      await _audioPlayer.setUrl(soundUrl);
      await _audioPlayer.play();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error playing sound: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sortedTeams = widget.game.ourteams.values.toList()
      ..sort((a, b) => b.points.compareTo(a.points));

    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 60),
          // Title
          Align(
            alignment: Alignment.center,
            child: Container(
              width: screenWidth * 0.9,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF1CA63E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'SCOREBOARD',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 50),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (sortedTeams.isNotEmpty)
                    Center(
                      child: TeamCard(
                        team: sortedTeams[0],
                        trophyImage: 'assets/images/firstplace.png',
                        height: 110,
                        backgroundColor: Colors.purple,
                        width: screenWidth * 0.6, // Center 1st place card
                      ),
                    ),
                  const SizedBox(height: 50),
                  if (sortedTeams.length > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TeamCard(
                          team: sortedTeams[1],
                          trophyImage: 'assets/images/secondplace.png',
                          height: 85,
                          backgroundColor: const Color(0xFFB69DF7),
                          width: screenWidth * 0.4,
                        ),
                        if (sortedTeams.length > 2)
                          TeamCard(
                            team: sortedTeams[2],
                            trophyImage: 'assets/images/thridplace.png',
                            height: 85,
                            backgroundColor: const Color(0xFFB69DF7),
                            width: screenWidth * 0.4,
                          ),
                      ],
                    ),
                  const SizedBox(height: 100),
                  if (sortedTeams.length > 3)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Wrap(
                        spacing: 16.0,
                        runSpacing: 16.0,
                        children: sortedTeams.sublist(3).map((team) {
                          return LastPlaces(
                            team: team,
                            width: screenWidth * 0.28,
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // New Game and Exit Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 60.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(175, 172, 76, 1),
                    minimumSize: Size(screenWidth * 0.6, 75),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CodeInputView()),
                    );
                  },
                  child: const Text(
                    'NEW GAME',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: Size(screenWidth * 0.3, 60),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CodeInputView()),
                    );
                  },
                  child: const Text(
                    'EXIT',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
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
