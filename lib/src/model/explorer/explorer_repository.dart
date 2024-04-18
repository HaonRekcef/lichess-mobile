import 'package:deep_pick/deep_pick.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:lichess_mobile/src/model/common/http.dart';
import 'package:lichess_mobile/src/model/explorer/explorer_game.dart';
import 'package:lichess_mobile/src/model/explorer/explorer_move.dart';

part 'explorer_repository.freezed.dart';

class ExplorerRepository {
  ExplorerRepository(this.client);

  final http.Client client;

  Future<ExplorerResponse> getExplorer(String fen) {
    return client.readJson(
      Uri.parse('https://explorer.lichess.ovh/lichess?fen=$fen'),
      mapper: _decodeExplorerResponse,
    );
  }
}

ExplorerResponse _decodeExplorerResponse(Map<String, dynamic> json) {
  return ExplorerResponse(
    white: pick(json['white']).asIntOrThrow(),
    draw: pick(json['draws']).asIntOrThrow(),
    black: pick(json['black']).asIntOrThrow(),
    moves: IList(pick(json['moves']).asListOrThrow(_moveFromPick)),
    topGames: IList(pick(json['topGames']).asListOrThrow(_gameFromPick)),
    recentGames: IList(pick(json['recentGames']).asListOrThrow(_gameFromPick)),
    opening: pick(json['opening']).asStringOrNull(),
  );
}

Move _moveFromPick(RequiredPick pick) {
  return Move(
    uci: pick('uci').asStringOrThrow(),
    san: pick('san').asStringOrThrow(),
    averageRating: pick('averageRating').asIntOrThrow(),
    white: pick('white').asIntOrThrow(),
    draws: pick('draws').asIntOrThrow(),
    black: pick('black').asIntOrThrow(),
  );
}

Game _gameFromPick(Pick pick) {
  return Game(
    uci: pick('uci').asStringOrThrow(),
    id: pick('id').asStringOrThrow(),
    winner: pick('winner').asStringOrThrow(),
    speed: pick('speed').asStringOrThrow(),
    mode: pick('mode').asStringOrThrow(),
    black: _playerFromPick(pick('black').required()),
    white: _playerFromPick(pick('white').required()),
    year: pick('year').asIntOrThrow(),
    month: pick('month').asStringOrThrow(),
  );
}

Player _playerFromPick(RequiredPick pick) {
  return Player(
    name: pick('name').asStringOrThrow(),
    rating: pick('rating').asIntOrThrow(),
  );
}

@freezed
class ExplorerResponse with _$ExplorerResponse {
  const factory ExplorerResponse({
    required int white,
    required int draw,
    required int black,
    required IList<Move> moves,
    required IList<Game> recentGames,
    required IList<Game> topGames,
    required String? opening,
  }) = _ExplorerResponse;
}
