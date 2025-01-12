class Game {
  final String? id; // Room code
  final int numofteams;
  final int numofplayers;
  final int numofwords;
  final int t1;
  final int t2;
  final int t3;
  final String? adminId; // ID of the room creator
  final Map<String, Team> ourteams;
  final int playersin; // Tracks the total number of players
  final LocationAdmin? locationadmin; // Admin's location

  Game({
    this.id,
    required this.numofteams,
    required this.numofplayers,
    required this.numofwords,
    required this.t1,
    required this.t2,
    required this.t3,
    required this.adminId,
    this.ourteams = const {},
    this.playersin = 0,
    this.locationadmin,
  });

  // Convert to Firestore-compatible JSON format
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "numofteams": numofteams,
      "numofplayers": numofplayers,
      "numofwords": numofwords,
      "t1": t1,
      "t2": t2,
      "t3": t3,
      "adminId": adminId,
      "ourteams": ourteams.map((key, team) => MapEntry(key, team.toJson())),
      "playersin": playersin,
      "locationadmin": locationadmin?.toJson(),
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
      adminId: data["adminId"], // Default to null if not present
      ourteams: (data["ourteams"] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, Team.fromJson(value)),
          ) ??
          {},
      playersin: data["playersin"] ?? 0,
      locationadmin: data["locationadmin"] != null
          ? LocationAdmin.fromJson(data["locationadmin"])
          : null,
    );
  }
}

class LocationAdmin {
  final double latitude;
  final double longitude;

  LocationAdmin({
    required this.latitude,
    required this.longitude,
  });

  // Convert to Firestore format
  Map<String, dynamic> toJson() {
    return {
      "latitude": latitude,
      "longitude": longitude,
    };
  }

  // Create a LocationAdmin object from Firestore data
  factory LocationAdmin.fromJson(Map<String, dynamic> data) {
    return LocationAdmin(
      latitude: data["latitude"]?.toDouble() ?? 0.0,
      longitude: data["longitude"]?.toDouble() ?? 0.0,
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
