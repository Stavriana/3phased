import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnotherTeamPlayingScreen extends StatefulWidget {
  final String roomCode;
  final String currentPlayerName;

  const AnotherTeamPlayingScreen({
    super.key,
    required this.roomCode,
    required this.currentPlayerName,
  });

  @override
  AnotherTeamPlayingScreenState createState() =>
      AnotherTeamPlayingScreenState();
}

class AnotherTeamPlayingScreenState extends State<AnotherTeamPlayingScreen> {
  late Timer timer;
  int timeRemaining = 0; // Timer duration in seconds
  String? currentTeamName;
  String? currentPlayerName;
  String? currentAvatarUrl;

  List<String> teamOrder = [];
  int currentTeamIndex = 0;

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  Future<void> _setupGame() async {
    try {
      // Fetch the room document
      final roomDoc = await FirebaseFirestore.instance
          .collection('Rooms')
          .doc(widget.roomCode)
          .get();

      if (!roomDoc.exists) throw 'Room not found';

      final roomData = roomDoc.data()!;
      final teams = roomData['ourteams'] as Map<String, dynamic>;

      // Use 't1' as the duration, default to 60 if not found
      timeRemaining = (roomData['t1'] ?? 60) as int;

      // Set up the team order
      teamOrder = teams.keys.toList();
      currentTeamIndex = roomData['currentTeamIndex'] ?? 0;

      // Initialize the current team and player
      await _initializeTeamAndPlayer(teams);
      _startTimer();
    } catch (e) {
      debugPrint('Error setting up the game: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _initializeTeamAndPlayer(Map<String, dynamic> teams) async {
    try {
      final currentTeamKey = teamOrder[currentTeamIndex];
      final teamData = teams[currentTeamKey] as Map<String, dynamic>;
      final playersQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('roomCode', isEqualTo: widget.roomCode)
          .get();

      // Filter users belonging to the current team
      final players = playersQuery.docs
          .where((doc) => doc['team'] == currentTeamKey)
          .map((doc) => doc.data()['name'] as String)
          .toList();

      // Filter out the current player
      final availablePlayers =
          players.where((player) => player != widget.currentPlayerName).toList();

      if (availablePlayers.isEmpty) {
        debugPrint('No players in the current team.');
        return;
      }

      // Randomly select a player
      final randomPlayerIndex = Random().nextInt(availablePlayers.length);
      currentPlayerName = availablePlayers[randomPlayerIndex];

      // Fetch the avatar for the selected player
      await _fetchPlayerAvatar(currentPlayerName!);

      setState(() {
        currentTeamName = teamData['name'];
      });
    } catch (e) {
      debugPrint('Error initializing team and player: $e');
    }
  }

  Future<void> _fetchPlayerAvatar(String playerName) async {
    try {
      // Fetch the user document based on the player's name
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isEqualTo: playerName)
          .get();

      if (userQuery.docs.isNotEmpty) {
        final userDoc = userQuery.docs.first;
        setState(() {
          currentAvatarUrl = userDoc['avatar'];
        });
      } else {
        throw 'Avatar not found for player $playerName';
      }
    } catch (e) {
      debugPrint('Error fetching avatar: $e');
    }
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeRemaining > 0) {
        setState(() {
          timeRemaining--;
        });
      } else {
        timer.cancel();
        _onTimerEnd();
      }
    });
  }

  void _onTimerEnd() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => AnotherTeamPlayingScreen(
          roomCode: widget.roomCode,
          currentPlayerName: currentPlayerName!,
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Another Team is Playing'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: Container(
        color: Colors.yellow, // Match GamePlayScreen background color
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              currentTeamName != null
                  ? '$currentTeamName is Playing'
                  : 'Loading Team...',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 40),
            // Avatar image or placeholder
            if (currentAvatarUrl != null)
              CircleAvatar(
                backgroundImage: NetworkImage(currentAvatarUrl!),
                radius: 80,
              )
            else
              const CircleAvatar(
                backgroundColor: Colors.grey,
                radius: 80,
                child: Icon(
                  Icons.person,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            const SizedBox(height: 20),
            Text(
              currentPlayerName ?? 'Loading Player...',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 40),
            // Timer and hourglass
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/hourglass.png',
                  width: 50,
                  height: 50,
                ),
                const SizedBox(width: 10),
                Text(
                  '00:${timeRemaining.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}