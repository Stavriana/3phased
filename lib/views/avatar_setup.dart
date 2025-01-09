import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'points_page.dart';
//import 'package:eksaminiaia/models/room.dart';

class AvatarSelectionScreen extends StatefulWidget {
  final String roomCode;
  final String team;

  const AvatarSelectionScreen({super.key, required this.roomCode, required this.team});

  @override
  AvatarSelectionScreenState createState() => AvatarSelectionScreenState();
}

class AvatarSelectionScreenState extends State<AvatarSelectionScreen> {
  String? selectedAvatarUrl;
  final TextEditingController nameController = TextEditingController();

  /// Function to pick an image and upload to Firebase Storage
  Future<void> _takePhotoAndUpload() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return;

    try {
      final file = File(image.path);
      final String fileName = 'avatars/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final uploadTask = FirebaseStorage.instance.ref(fileName).putFile(file);

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      if (!mounted) return;

      setState(() {
        selectedAvatarUrl = downloadUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo uploaded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload photo')),
        );
      }
    }
  }

  /// Function to save player data
  Future<void> savePlayerData() async {
    if (nameController.text.isEmpty || selectedAvatarUrl == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your name and select an avatar')),
        );
      }
      return;
    }

    try {
      final teamPath = 'ourteams.${widget.team}.players';
      final roomDocRef = FirebaseFirestore.instance.collection('Rooms').doc(widget.roomCode);

      // Fetch only the `playersin` field from Firestore
      final roomDoc = await roomDocRef.get(const GetOptions(
      source: Source.serverAndCache,
    ));
      // Increment playersin count
      final currentPlayersIn = roomDoc.data()?['playersin'] ?? 0;
      final updatedPlayersIn = currentPlayersIn + 1;

      await FirebaseFirestore.instance.collection('Rooms').doc(widget.roomCode).update({
        teamPath: FieldValue.arrayUnion([
          {'name': nameController.text, 'avatar': selectedAvatarUrl}
        ]),
        'playersin': updatedPlayersIn, // Save the incremented value
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Player added successfully')),
      );

      // Navigate to the gameplay screen or next stage
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PointsPage(
              roomCode: widget.roomCode,
              //game: widget.Game,
              //team: widget.team,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add player: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Avatar Selection for Team: ${widget.team}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter Your Name:', style: TextStyle(fontSize: 16)),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Your Name',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _takePhotoAndUpload,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take a Photo'),
            ),
            const SizedBox(height: 20),
            const Text('Choose Your Avatar:', style: TextStyle(fontSize: 16)),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('avatars').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No avatars available'));
                  }

                  final avatars = snapshot.data!.docs;

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: avatars.length,
                    itemBuilder: (context, index) {
                      final avatarData = avatars[index].data() as Map<String, dynamic>;
                      final avatarUrl = avatarData['url'];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedAvatarUrl = avatarUrl;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: selectedAvatarUrl == avatarUrl
                                ? Border.all(color: Colors.blue, width: 3)
                                : null,
                          ),
                          child: ClipOval(
                            child: Image.network(
                              avatarUrl,
                              fit: BoxFit.cover,
                              width: 80,
                              height: 80,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(Icons.error, color: Colors.red),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: savePlayerData,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}