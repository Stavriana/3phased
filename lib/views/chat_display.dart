import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'say_what.dart';

class PlayerDisplayScreen extends StatelessWidget {
  final String roomCode;
  final String team;

  const PlayerDisplayScreen({super.key, required this.roomCode, required this.team});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(height: 20),
          Container(
            width: double.infinity,
            color: Colors.orange,
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Room Code: $roomCode',
              textAlign: TextAlign.center,
              style: TextStyle(
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
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return Center(child: Text('No data found'));
                  }

                  final data = snapshot.data?.data() as Map<String, dynamic>?;
                  if (data == null || !data.containsKey('ourteams')) {
                    return Center(child: Text('No teams available'));
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
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // Reduce to 3 to allow more space for each avatar
                      crossAxisSpacing: 16.0, // Space between columns
                      mainAxisSpacing: 16.0, // Space between rows
                      childAspectRatio: 0.8, // Adjust to allow full display of avatars and names
                    ),
                    itemCount: allPlayers.length,
                    itemBuilder: (context, index) {
                      final player = allPlayers[index];
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(player['avatar'] ?? ''),
                            radius: 50, // Larger radius for better visibility
                            onBackgroundImageError: (error, stackTrace) =>
                                Icon(Icons.error, color: Colors.red),
                          ),
                          SizedBox(height: 5),
                          Text(
                            player['name'] ?? 'Unknown',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16, // Larger font for readability
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2, // Allow up to 2 lines for names
                            overflow: TextOverflow.ellipsis, // Truncate if necessary
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
                    width: 150, // Increased width for larger button
                    height: 60, // Increased height for larger button
                  ),
                ),
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
                    'assets/images/chat.png',
                    width: 100, // Keep this unchanged or adjust as needed
                    height: 50,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
