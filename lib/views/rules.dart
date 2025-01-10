import 'package:flutter/material.dart';

import 'code_input_view.dart';



class RulesPageApp extends StatelessWidget {
  const RulesPageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Rules Header - Styled like SKIP Button
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6, // 80% of screen width
                  padding: const EdgeInsets.symmetric(vertical: 15), // Padding inside the box
                  decoration: BoxDecoration(
                    color: Colors.red, // Red background
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  child: const Center(
                    child: Text(
                      'RULES',
                      style: TextStyle(
                        color: Colors.black, // Text color
                        fontSize: 22, // Font size
                        fontWeight: FontWeight.bold, // Bold text
                        letterSpacing: 1.5, // Optional letter spacing
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Rules Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "At the start of the game, all players submit their chosen words, which will be used throughout the game. The game is played in three rounds:",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Round 1
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "ROUND 1: Say What?\n",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                  fontSize: 16,
                                  backgroundColor: Color(0xFFE0E0E0),
                                ),
                              ),
                              TextSpan(
                                text:
                                    "Each player describes the word that appears on their screen without saying the word itself.",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Round 2
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "ROUND 2: Pantomime\n",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  fontSize: 16,
                                  backgroundColor: Color(0xFFE0E0E0),
                                ),
                              ),
                              TextSpan(
                                text:
                                    "Each player uses gestures to act out the word that appears, helping their teammates guess it.",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Round 3
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: "ROUND 3: One Word\n",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  fontSize: 16,
                                  backgroundColor: Color(0xFFE0E0E0),
                                ),
                              ),
                              TextSpan(
                                text:
                                    "Each player describes the word that appears using only one word. If a player says more than one word, their turn ends immediately, and the next team plays.",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Final Description
                        const Text(
                          "The game is played against the clock and players cannot pass a word.",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Skip Button
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const CodeInputView()),
                  );
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6, // Same width as RULES
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCAB3F9), // Purple background
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                  ),
                  child: const Center(
                    child: Text(
                      'SKIP',
                      style: TextStyle(
                        color: Colors.black, // Text color
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}