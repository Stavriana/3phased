import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PantomimeScreen extends StatefulWidget {
  final String roomCode;
  final String team;

  const PantomimeScreen({super.key, required this.roomCode, required this.team});

  @override
  PantomimeScreenState createState() => PantomimeScreenState();
}

class PantomimeScreenState extends State<PantomimeScreen> {
  List<String> words = []; // List of words to display
  String currentWord = '';
  int points = 0;
  Timer? timer;
  int timeRemaining = 0; // Time in seconds

  @override
  void initState() {
    super.initState();
    _fetchGameData();
  }

  Future<void> _fetchGameData() async {
  try {
    final doc = await FirebaseFirestore.instance.collection('Rooms').doc(widget.roomCode).get();
    if (!doc.exists) throw 'Room not found';

    final data = doc.data()!;
    final roomWords = data['words'] as List<dynamic>;

    // Use 't2' as the duration, default to 60 if not found or null
    final duration = (data['t2'] ?? 60) as int;

    // Extract and cast words to List<String>
    words = roomWords
        .expand((wordData) => (wordData['words'] as List<dynamic>).map((word) => word.toString()))
        .toList();

    if (words.isEmpty) throw 'No words found in the room';

    // Shuffle words to display randomly
    words.shuffle(Random());

    // Start timer and display the first word
    setState(() {
      timeRemaining = duration;
      _startTimer();
      _getNextWord();
    });
  } catch (e) {
    debugPrint('Error fetching game data: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching words: $e')),
      );
    }
  }
}

  /// Start the countdown timer
  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeRemaining > 0) {
        setState(() {
          timeRemaining--;
        });
      } else {
        timer.cancel();
        _onStop(); // Navigate to the next screen when the timer ends
      }
    });
  }

  /// Get the next word to display
  void _getNextWord() {
    if (words.isNotEmpty) {
      setState(() {
        currentWord = words.removeAt(0);
      });
    } else {
      _onStop(); // No more words, stop the game
    }
  }

  /// Handle "Done" button press
  Future<void> _onDone() async {
    setState(() {
      points += 10; // Add 10 points
    });

    // Update points in Firestore
    await FirebaseFirestore.instance.collection('Rooms').doc(widget.roomCode).update({
      'ourteams.${widget.team}.points': FieldValue.increment(10),
    });

    _getNextWord();
  }

  /// Handle "Stop" button press
  void _onStop() {
    timer?.cancel();
    Navigator.pushNamed(context, '/nextScreen'); // Update with your desired route
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
        title: const Text('Pantomime Game'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Container(
        color: Colors.lightGreen.shade100, // Light green background
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'PANTOMIME', // Updated title
              style: TextStyle(
                fontSize: 50, // Larger font size for the title
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 40),
            // Boom cloud image with the word
            Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/images/boom.png',
                  width: 350, // Larger boom image
                  height: 350,
                  fit: BoxFit.contain,
                ),
                Text(
                  currentWord.isNotEmpty ? currentWord : 'Loading...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 36, // Larger font size for the word
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Timer and hourglass
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/hourglass.png',
                  width: 80, // Increased size for hourglass
                  height: 80,
                ),
                const SizedBox(width: 20),
                Text(
                  '00:${timeRemaining.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 48, // Larger font size for the timer
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            // Done button
            GestureDetector(
              onTap: _onDone,
              child: Image.asset(
                'assets/images/done.png',
                width: 250, // Larger button
                height: 100,
              ),
            ),
            const SizedBox(height: 20),
            // Stop button
            GestureDetector(
              onTap: _onStop,
              child: Image.asset(
                'assets/images/stop.png',
                width: 250, // Larger button
                height: 100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}