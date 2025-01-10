import 'dart:async';
import 'dart:math';
import 'code_input_view.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'another_player_ow.dart';

class OneWordScreen extends StatefulWidget {
  final String roomCode;
  final String team;

  const OneWordScreen({super.key, required this.roomCode, required this.team});

  @override
  OneWordScreenState createState() => OneWordScreenState();
}

class OneWordScreenState extends State<OneWordScreen> {
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
      final doc = await FirebaseFirestore.instance
          .collection('Rooms')
          .doc(widget.roomCode)
          .get();

      if (!doc.exists) throw 'Room not found';

      final data = doc.data()!;
      final roomWords = data['words'] as List<dynamic>;

      final duration = (data['t3'] ?? 60) as int;  // Changed 't2' to 't3'

      words = roomWords.map((word) => word.toString()).toList();

      if (words.isEmpty) throw 'No words found in the room';

      words.shuffle(Random());

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

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeRemaining > 0) {
        setState(() {
          timeRemaining--;
        });
      } else {
        timer.cancel();
        _onStop();
      }
    });
  }

  void _getNextWord() {
    if (words.isNotEmpty) {
      setState(() {
        currentWord = words.removeAt(0);
      });
    } else {
      _onStop();
    }
  }

  Future<void> _onDone() async {
    setState(() {
      points += 10;
    });

    await FirebaseFirestore.instance.collection('Rooms').doc(widget.roomCode).update({
      'ourteams.${widget.team}.points': FieldValue.increment(10),
    });

    _getNextWord();
  }

  void _onStop() {
    timer?.cancel();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OneWordTeamPlayingScreen(
          roomCode: widget.roomCode,
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
      body: Stack(
        children: [
          Container(
            color: Colors.green,  // Changed background color to green
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'ONE WORD',  // Changed title to 'ONE WORD'
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 40),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/images/boom.png',
                      width: 350,
                      height: 350,
                      fit: BoxFit.contain,
                    ),
                    Text(
                      currentWord.isNotEmpty ? currentWord : 'Loading...',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/hourglass.png',
                      width: 80,
                      height: 80,
                    ),
                    const SizedBox(width: 20),
                    Text(
                      '00:${timeRemaining.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: _onDone,
                  child: Image.asset(
                    'assets/images/done.png',
                    width: 250,
                    height: 100,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _onStop,
                  child: Image.asset(
                    'assets/images/stop.png',
                    width: 250,
                    height: 100,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const CodeInputView(),
      ),
    );
                },
                child: Image.asset(
                  'assets/images/house.png',
                  width: 40,
                  height: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
