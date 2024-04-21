class ExplorerMove {
  final String uci;
  final String san;
  final int averageRating;
  final int white;
  final int draws;
  final int black;

  ExplorerMove({
    required this.uci,
    required this.san,
    required this.averageRating,
    required this.white,
    required this.draws,
    required this.black,
  });
}
