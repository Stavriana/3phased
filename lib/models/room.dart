import 'dart:developer';

class Game {
  final String? id; // 4-digit code
  final int numofteams;
  final int numofplayers;
  final int numofwords;
  final int t1;
  final int t2;
  final int t3;
  final Map<String, Team> ourteams; // Optional field to store team information

  const Game({
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
    log('Converting Game to JSON: $this', name: 'GameModel');
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
    log('Converting Firestore Data to Game: $data', name: 'GameModel');
    return Game(
      id: id,
      numofteams: data["numofteams"] ?? 0,
      numofplayers: data["numofplayers"] ?? 0,
      numofwords: data["numofwords"] ?? 0,
      t1: data["t1"] ?? 0,
      t2: data["t2"] ?? 0,
      t3: data["t3"] ?? 0,
      ourteams: (data["ourteams"] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, Team.fromJson(value)),
          ) ??
          {},
    );
  }
}

class Team {
  final String name;
  final String color;
  final List<Player> players;

  const Team({
    required this.name,
    this.color = "", // Default empty string
    this.players = const [], // Default empty list
  });

  // Convert to Firestore format
  Map<String, dynamic> toJson() {
    log('Converting Team to JSON: $this', name: 'TeamModel');
    return {
      "name": name,
      "color": color,
      "players": players.map((player) => player.toJson()).toList(),
    };
  }

  // Create a Team object from Firestore data
  factory Team.fromJson(Map<String, dynamic> data) {
    log('Converting Firestore Data to Team: $data', name: 'TeamModel');
    return Team(
      name: data["name"] ?? "",
      color: data["color"] ?? "",
      players: (data["players"] as List<dynamic>?)
              ?.map((player) => Player.fromJson(player))
              .toList() ??
          [],
    );
  }
}

class Player {
  final String name;
  final String id;

  const Player({
    required this.name,
    required this.id,
  });

  // Convert to Firestore format
  Map<String, dynamic> toJson() {
    log('Converting Player to JSON: $this', name: 'PlayerModel');
    return {
      "name": name,
      "id": id,
    };
  }

  // Create a Player object from Firestore data
  factory Player.fromJson(Map<String, dynamic> data) {
    log('Converting Firestore Data to Player: $data', name: 'PlayerModel');
    return Player(
      name: data["name"] ?? "",
      id: data["id"] ?? "",
    );
  }
}
