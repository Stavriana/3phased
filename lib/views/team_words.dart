import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'avatar_setup.dart';
import 'code_input_view.dart';

class TeamWordsScreen extends StatefulWidget {
  final String roomCode;

  const TeamWordsScreen({super.key, required this.roomCode});

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
      // Append words to Firestore
      await FirebaseFirestore.instance.collection('Rooms').doc(widget.roomCode).update({
        'words': FieldValue.arrayUnion(words),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Words saved successfully')),
        );

        // Navigate to AvatarSelectionScreen with the selected team
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AvatarSelectionScreen(
              roomCode: widget.roomCode,
              team: selectedTeam!, // Pass the selected team
            ),
          ),
        );
      }
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
        title: const Text('Choose Team and Type Your Words'),
      ),
      body: Stack(
        children: [
          FutureBuilder<DocumentSnapshot>(
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

              // Initialize word controllers
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
                  Center(
                    child: GestureDetector(
                      onTap: _saveWordsAndProceed, // Trigger navigation when the image is tapped
                      child: Image.asset(
                        'assets/images/ready_arrow.png', // Path to your image
                        height: 100, // Adjust size as needed
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CodeInputView()),
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

  @override
  void dispose() {
    // Dispose of controllers
    for (var controller in wordControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
