import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AvatarSelectionScreen extends StatefulWidget {
  const AvatarSelectionScreen({super.key});  // Use super.key for the constructor

  @override
  AvatarSelectionScreenState createState() => AvatarSelectionScreenState();
}

class AvatarSelectionScreenState extends State<AvatarSelectionScreen> {
  String? selectedAvatarUrl;
  final TextEditingController nameController = TextEditingController();
  final Logger logger = Logger();

  // Function to pick an image using the camera and upload to Firebase Storage
  Future<void> _takePhotoAndUpload() async {
    // Open the camera and pick an image
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) {
      // If no image was picked, exit
      return;
    }

    // Get the file from the picked image
    File file = File(image.path);

    try {
      // Upload the image to Firebase Storage
      String fileName = 'avatars/${DateTime.now().millisecondsSinceEpoch}.jpg';
      UploadTask uploadTask = FirebaseStorage.instance.ref(fileName).putFile(file);

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();  // Get the URL of the uploaded image

      // Once uploaded, save the URL to Firestore
      await FirebaseFirestore.instance.collection('avatars').add({
        'url': downloadUrl, // Save the URL of the image in Firestore
      });

      // Save the URL to the selectedAvatarUrl variable
      setState(() {
        selectedAvatarUrl = downloadUrl;
      });

      // Check if the widget is still mounted before showing the SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Photo taken and uploaded successfully')),
        );
      }
    } catch (e) {
      logger.e('Error uploading photo: $e');
      
      // Check if the widget is still mounted before showing the SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload photo')),
        );
      }
    }
  }

 // Function to save the player's name and avatar selection to Firestore
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
    await FirebaseFirestore.instance.collection('users').add({
      'name': nameController.text,
      'avatar': selectedAvatarUrl,
    });

    // Show success message only if the widget is still mounted
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Player data saved successfully')),
      );
    }
  } catch (e) {
    // Handle error only if the widget is still mounted
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save player data')),
      );
    }
    logger.e('Error saving player data: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avatar Selection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Your Name:',
              style: TextStyle(fontSize: 16),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Your Name',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                logger.d('Open camera button clicked');
                _takePhotoAndUpload();  // Open the camera and upload photo
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take a Photo'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Or choose your avatar:',
              style: TextStyle(fontSize: 16),
            ),
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
                      final avatarUrl = avatarData['url']; // The URL from Firestore

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedAvatarUrl = avatarUrl;  // Update the selected avatar
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            // Apply circular border here as well
                            shape: BoxShape.circle,
                            border: selectedAvatarUrl == avatarUrl
                                ? Border.all(color: Colors.blue, width: 3)
                                : null,
                          ),
                          child: ClipOval(
                            // Ensure the image is a perfect circle
                            child: Image.network(
                              avatarUrl,  // Display the avatar image from the URL
                              fit: BoxFit.cover,
                              width: 80,  // Define the size for the circular image
                              height: 80, // Define the size for the circular image
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(child: Icon(Icons.error, color: Colors.red));
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
                onPressed: savePlayerData,  // Save name and avatar data
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
