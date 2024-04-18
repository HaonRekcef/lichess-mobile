class Game {
  final String? uci;
  final String id;
  final String winner;
  final String speed;
  final String mode;
  final Player black;
  final Player white;
  final int year;
  final String month;

  Game({
    required this.uci,
    required this.id,
    required this.winner,
    required this.speed,
    required this.mode,
    required this.black,
    required this.white,
    required this.year,
    required this.month,
  });
}

class Player {
  final String name;
  final int rating;

  Player({
    required this.name,
    required this.rating,
  });
}
