class ExplorerGame {
  final String? uci;
  final String id;
  final String? winner;
  final String speed;
  final String mode;
  final ExplorerPlayer black;
  final ExplorerPlayer white;
  final int year;
  final String month;

  ExplorerGame({
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

class ExplorerPlayer {
  final String name;
  final int rating;

  ExplorerPlayer({
    required this.name,
    required this.rating,
  });
}
