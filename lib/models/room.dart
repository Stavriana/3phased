//import 'dart:developer';

class Game {
  final String? id; // Room code
  final int numofteams;
  final int numofplayers;
  final int numofwords;
  final int t1;
  final int t2;
  final int t3;
  final Map<String, Team> ourteams;

  Game({
    this.id,
    required this.numofteams,
    required this.numofplayers,
    required this.numofwords,
    required this.t1,
    required this.t2,
    required this.t3,
    this.ourteams = const {}, // Default value: empty map
  });

  // Convert to Firestore format
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "numofteams": numofteams,
      "numofplayers": numofplayers,
      "numofwords": numofwords,
      "t1": t1,
      "t2": t2,
      "t3": t3,
      "ourteams": ourteams.map((key, team) => MapEntry(key, team.toJson())),
    };
  }

  // Create a Game object from Firestore data
  factory Game.fromFirestore(String id, Map<String, dynamic> data) {
    return Game(
      id: id,
      numofteams: data["numofteams"] ?? 0, // Default to 0 if null
      numofplayers: data["numofplayers"] ?? 0,
      numofwords: data["numofwords"] ?? 0,
      t1: data["t1"] ?? 0,
      t2: data["t2"] ?? 0,
      t3: data["t3"] ?? 0,
      ourteams: (data["ourteams"] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, Team.fromJson(value)),
          ) ??
          {}, // Default to empty map if null
    );
  }
}

class Team {
  String name;
  String color;
  List<Player> players;
  int points;

  Team({
    required this.name,
    this.color = "", // Default to empty string
    this.players = const [], // Default to an empty list
    this.points = 0, // Default to 0
  });

  // Convert to Firestore format
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "color": color,
      "players": players.map((player) => player.toJson()).toList(),
      "points": points,
    };
  }

  // Create a Team object from Firestore data
  factory Team.fromJson(Map<String, dynamic> data) {
    return Team(
      name: data["name"] ?? "", // Default to empty string if null
      color: data["color"] ?? "", // Default to empty string if null
      players: (data["players"] as List<dynamic>?)
              ?.map((player) => Player.fromJson(player))
              .toList() ??
          [], // Default to an empty list if players is null
      points: data["points"] ?? 0, // Default to 0 if points is null
    );
  }
}

class Player {
  String name;
  String id;

  Player({
    required this.name,
    required this.id,
  });

  // Convert to Firestore format
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "id": id,
    };
  }

  // Create a Player object from Firestore data
  factory Player.fromJson(Map<String, dynamic> data) {
    return Player(
      name: data["name"] ?? "", // Default to empty string if null
      id: data["id"] ?? "", // Default to empty string if null
    );
  }
}
