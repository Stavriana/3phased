import 'say_what.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chatroom_screen.dart';

class PlayerDisplayScreen extends StatelessWidget {
  final String roomCode;
  final String team;

  const PlayerDisplayScreen({super.key, required this.roomCode, required this.team});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                color: Colors.orange,
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Room Code: $roomCode',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('Rooms').doc(roomCode).get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data == null) {
                        return const Center(child: Text('No data found'));
                      }

                      final data = snapshot.data?.data() as Map<String, dynamic>?; // Removed unnecessary cast
                      if (data == null || !data.containsKey('ourteams')) {
                        return const Center(child: Text('No teams available'));
                      }

                      var teams = data['ourteams'] as Map<String, dynamic>;
                      List<Map<String, dynamic>> allPlayers = [];

                      teams.forEach((teamKey, teamData) {
                        final players = teamData['players'] as List<dynamic>?;
                        if (players != null) {
                          allPlayers.addAll(players.cast<Map<String, dynamic>>());
                        }
                      });

                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: allPlayers.length,
                        itemBuilder: (context, index) {
                          final player = allPlayers[index];
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(player['avatar'] ?? ''),
                                radius: 50,
                                onBackgroundImageError: (error, stackTrace) =>
                                    const Icon(Icons.error, color: Colors.red),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                player['name'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GamePlayScreen(
                              roomCode: roomCode,
                              team: team,
                            ),
                          ),
                        );
                      },
                      child: Image.asset(
                        'assets/images/start.png',
                        width: 150,
                        height: 60,
                      ),
                    ),
                    const Spacer(flex: 2),
                    GestureDetector(
                      onTap: () async {
                        try {
                          final docSnapshot = await FirebaseFirestore.instance
                              .collection('Rooms')
                              .doc(roomCode)
                              .get();

                          if (!context.mounted) return;

                          final data = docSnapshot.data();
                          if (data == null || !data.containsKey('chosen')) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No chosen player available')),
                            );
                            return;
                          }

                          final chosenPlayers = data['chosen'] as List<dynamic>;
                          if (chosenPlayers.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No chosen player available')),
                            );
                            return;
                          }

                          final chosenPlayer = chosenPlayers.first as Map<String, dynamic>;

                          if (!context.mounted) return;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatroomScreen(
                                roomCode: roomCode,
                                playerName: chosenPlayer['name'] ?? 'Unknown',
                                avatarUrl: chosenPlayer['avatar'] ?? '',
                              ),
                            ),
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}')),
                            );
                          }
                        }
                      },
                      child: Image.asset(
                        'assets/images/chat.png',
                        width: 100,
                        height: 50,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
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