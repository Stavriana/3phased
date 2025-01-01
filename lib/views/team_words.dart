import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'say_what.dart'; // Import the gameplay screen

class TeamWordsScreen extends StatefulWidget {
  const TeamWordsScreen({super.key, required this.roomCode});

  final String roomCode;

  @override
  TeamWordsScreenState createState() => TeamWordsScreenState();
}

class TeamWordsScreenState extends State<TeamWordsScreen> {
  String? selectedTeam;
  List<TextEditingController> wordControllers = [];

  /// Save words and navigate to the next screen
  Future<void> _saveWordsAndProceed() async {
    if (selectedTeam == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a team')),
        );
      }
      return;
    }

    final words = wordControllers.map((controller) => controller.text.trim()).toList();
    if (words.any((word) => word.isEmpty)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all the words')),
        );
      }
      return;
    }

    try {
      // Save structured data to Firestore
      final playerData = {
        'team': selectedTeam,
        'words': words,
      };

      await FirebaseFirestore.instance.collection('Rooms').doc(widget.roomCode).update({
        'words': FieldValue.arrayUnion([playerData]), // Append player data to the words array
      });

      if (!mounted) return;

      // Navigate to the gameplay screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GamePlayScreen(
            roomCode: widget.roomCode,
            team: selectedTeam!,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save words: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Team and Type your Words'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('Rooms').doc(widget.roomCode).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Room not found'));
          }

          final roomData = snapshot.data!.data() as Map<String, dynamic>;
          final teams = roomData['ourteams'] as Map<String, dynamic>;
          final numOfWords = roomData['numofwords'] as int;

          // Initialize controllers if not already initialized
          if (wordControllers.isEmpty) {
            wordControllers = List.generate(numOfWords, (_) => TextEditingController());
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const Text(
                'CHOOSE YOUR TEAM',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              ...teams.entries.map((team) {
                return ListTile(
                  leading: Radio<String>(
                    value: team.key,
                    groupValue: selectedTeam,
                    onChanged: (value) {
                      setState(() {
                        selectedTeam = value;
                      });
                    },
                  ),
                  title: Text(team.value['name']),
                );
              }),
              const SizedBox(height: 24.0),
              const Text(
                'INSERT YOUR WORDS',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              ...List.generate(numOfWords, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    controller: wordControllers[index],
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Word ${index + 1}',
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24.0),
              Center(
                child: GestureDetector(
                  onTap: _saveWordsAndProceed,
                  child: Image.asset(
                    'assets/images/ready_arrow.png',
                    width: 200, // Increased size
                    height: 200, // Increased size
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of all controllers
    for (var controller in wordControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
