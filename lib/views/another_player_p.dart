import 'dart:async';
import 'one_word.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PantomimeTeamPlayingScreen extends StatefulWidget {
  final String roomCode;

  const PantomimeTeamPlayingScreen({
    super.key,
    required this.roomCode,
  });

  @override
  PantomimeTeamPlayingScreenState createState() =>
      PantomimeTeamPlayingScreenState();
}

class PantomimeTeamPlayingScreenState
    extends State<PantomimeTeamPlayingScreen> {
  Timer? timer;
  int timeRemaining = 0;
  String? currentTeamName;
  String? currentPlayerName;
  String? currentAvatarUrl;

  List<String> teamOrder = [];
  Map<String, List<Map<String, dynamic>>> allTeamsWithPlayers = {};
  int currentTeamIndex = 0;

  List<String> playedPlayers = [];
  int defaultTimerDuration = 10;

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  Future<void> _setupGame() async {
    try {
      final roomDoc = await FirebaseFirestore.instance
          .collection('Rooms')
          .doc(widget.roomCode)
          .get();

      if (!roomDoc.exists) {
        throw 'Room with code ${widget.roomCode} not found.';
      }

      final roomData = roomDoc.data()!;
      final teams = roomData['ourteams'] as Map<String, dynamic>;

      defaultTimerDuration = roomData['t3'] ?? 10;
      timeRemaining = defaultTimerDuration;

      teamOrder = teams.keys.toList();
      currentTeamIndex = 0;

      for (var teamKey in teamOrder) {
        final teamData = teams[teamKey] as Map<String, dynamic>;
        final players = (teamData['players'] as List<dynamic>)
            .map((player) => player as Map<String, dynamic>)
            .toList();
        allTeamsWithPlayers[teamKey] = players;
      }

      await _initializeTeamAndPlayer();
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
    debugPrint('Initializing team and player...');

    final allPlayers =
        allTeamsWithPlayers.values.expand((players) => players).toList();
    if (playedPlayers.length == allPlayers.length) {
      debugPrint('All players have played.');
      _navigateToPantomimeScreen();
      return;
    }

    final currentTeamKey = teamOrder[currentTeamIndex];
    final teamPlayers = allTeamsWithPlayers[currentTeamKey] ?? [];

    final availablePlayers = teamPlayers
        .where((player) => !playedPlayers.contains(player['name']))
        .toList();

    if (availablePlayers.isEmpty) {
      currentTeamIndex = (currentTeamIndex + 1) % teamOrder.length;
      await _initializeTeamAndPlayer();
      return;
    }

    final selectedPlayer = availablePlayers.first;

    playedPlayers.add(selectedPlayer['name']);

    setState(() {
      currentPlayerName = selectedPlayer['name'];
      currentAvatarUrl = selectedPlayer['avatar'];
      currentTeamName = currentTeamKey;
      timeRemaining = defaultTimerDuration;
    });

    currentTeamIndex = (currentTeamIndex + 1) % teamOrder.length;
    _startTimer();
  }

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (timeRemaining > 0) {
        setState(() {
          timeRemaining--;
        });
      } else {
        t.cancel();
        _handleTimerEnd();
      }
    });
  }

  void _handleTimerEnd() async {
    debugPrint('Timer ended. Moving to the next player or team...');
    if (playedPlayers.length ==
        allTeamsWithPlayers.values.expand((players) => players).length) {
      debugPrint('All players have played.');
      _navigateToPantomimeScreen();
      return;
    }

    await _initializeTeamAndPlayer();
  }

  void _navigateToPantomimeScreen() {
    debugPrint('Navigating to One Word Screen...');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OneWordScreen(
          roomCode: widget.roomCode,
          team: currentTeamName ?? "Unknown Team",
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PANTOMIME'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        color: Colors.blue,
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
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
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
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
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
                    color: Colors.white,
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
