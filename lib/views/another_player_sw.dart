import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnotherTeamPlayingScreen extends StatefulWidget {
  final String roomCode;

  const AnotherTeamPlayingScreen({
    super.key,
    required this.roomCode,
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
  Map<String, List<Map<String, dynamic>>> allTeamsWithPlayers = {};
  int currentTeamIndex = 0;

  List<String> playedPlayers = []; // Tracks players who have already played
  bool allPlayersPlayed = false; // Tracks if all players have played

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

      if (!roomDoc.exists) {
        throw 'Room with code ${widget.roomCode} not found.';
      }

      final roomData = roomDoc.data()!;
      debugPrint('Room Data: $roomData');

      final teams = roomData['ourteams'] as Map<String, dynamic>;

      // Use 't1' as the duration, default to 60 if not found
      timeRemaining = roomData.containsKey('t1') ? roomData['t1'] as int : 60;

      // Set up the team order
      teamOrder = teams.keys.toList();
      currentTeamIndex = 0;

      // Populate all teams with their players
      for (var teamKey in teamOrder) {
        final teamData = teams[teamKey] as Map<String, dynamic>;
        final players = (teamData['players'] as List<dynamic>)
            .map((player) => player as Map<String, dynamic>)
            .toList();
        allTeamsWithPlayers[teamKey] = players;
      }

      debugPrint('All Teams with Players: $allTeamsWithPlayers');

      // Start with the first team
      await _initializeTeamAndPlayer();
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

  Future<void> _initializeTeamAndPlayer() async {
    try {
      // Check if all players have played
      if (playedPlayers.length ==
          allTeamsWithPlayers.values
              .expand((players) => players)
              .length) {
        setState(() {
          allPlayersPlayed = true;
        });
        debugPrint('All players have played.');
        _navigateToPantomimeScreen();
        return;
      }

      final currentTeamKey = teamOrder[currentTeamIndex];
      final teamPlayers = allTeamsWithPlayers[currentTeamKey] ?? [];

      debugPrint('Current Team Key: $currentTeamKey');
      debugPrint('Players in Team: $teamPlayers');

      // Filter out players who have already played
      final availablePlayers = teamPlayers
          .where((player) => !playedPlayers.contains(player['name']))
          .toList();

      debugPrint('Available Players: $availablePlayers');

      if (availablePlayers.isEmpty) {
        debugPrint('No available players in team $currentTeamKey.');

        // Move to the next team
        currentTeamIndex = (currentTeamIndex + 1) % teamOrder.length;
        await _initializeTeamAndPlayer(); // Recursively call for the next team
        return;
      }

      // Randomly select a player
      final randomPlayerIndex = Random().nextInt(availablePlayers.length);
      final selectedPlayer = availablePlayers[randomPlayerIndex];

      currentPlayerName = selectedPlayer['name'];
      currentAvatarUrl = selectedPlayer['avatar'];

      // Mark the player as played
      playedPlayers.add(currentPlayerName!);

      setState(() {
        currentTeamName = currentTeamKey;
      });

      debugPrint('Selected Player: $currentPlayerName');
      debugPrint('Selected Player Avatar: $currentAvatarUrl');
    } catch (e) {
      debugPrint('Error initializing team and player: $e');
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

  void _onTimerEnd() async {
    if (allPlayersPlayed) {
      // Navigate to the PantomimeScreen when all players have played
      _navigateToPantomimeScreen();
      return;
    }

    // Move to the next team after timer ends
    currentTeamIndex = (currentTeamIndex + 1) % teamOrder.length;

    // Initialize the next team and player
    await _initializeTeamAndPlayer();

    // Restart the timer
    _startTimer();
  }

  void _navigateToPantomimeScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const PantomimeScreen(),
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
        title: const Text('SAY WHAT?'),
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
            CircleAvatar(
              backgroundImage: currentAvatarUrl != null
                  ? NetworkImage(currentAvatarUrl!)
                  : null,
              backgroundColor: currentAvatarUrl == null ? Colors.grey : null,
              radius: 80,
              child: currentAvatarUrl == null
                  ? const Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.white,
                    )
                  : null,
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

class PantomimeScreen extends StatelessWidget {
  const PantomimeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantomime Screen'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Text(
          'Welcome to Pantomime!',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
