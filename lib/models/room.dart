class Game {
  final String? id; // 4-digit code
  final int numofteams;
  final int numofplayers;
  final int numofwords;
  final int t1;
  final int t2;
  final int t3;

  const Game({
    this.id,
    required this.numofteams,
    required this.numofplayers,
    required this.numofwords,
    required this.t1,
    required this.t2,
    required this.t3,
  });

  // Convert to Firestore format
  Map<String, dynamic> toJson() {
    return {
      "numofplayers": numofplayers,
      "numofteams": numofteams,
      "numofwords": numofwords,
      "t1": t1,
      "t2": t2,
      "t3": t3,
    };
  }

  // Create a Game object from Firestore data
  factory Game.fromFirestore(String id, Map<String, dynamic> data) {
    return Game(
      id: id,
      numofteams: data["numofteams"] ?? 0,
      numofplayers: data["numofplayers"] ?? 0,
      numofwords: data["numofwords"] ?? 0,
      t1: data["t1"] ?? 0,
      t2: data["t2"] ?? 0,
      t3: data["t3"] ?? 0,
    );
  }
}
