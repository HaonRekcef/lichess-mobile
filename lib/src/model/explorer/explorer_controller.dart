import 'dart:async';
import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:lichess_mobile/src/model/common/http.dart';
import 'package:lichess_mobile/src/model/common/uci.dart';
import 'package:lichess_mobile/src/model/explorer/explorer_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'explorer_controller.freezed.dart';
part 'explorer_controller.g.dart';

@riverpod
class ExplorerController extends _$ExplorerController {
  ExplorerController() {
    Future.microtask(() => fetchExplorer(fen: state.position.fen));
  }

  ExplorerRepository _repository(http.Client client) =>
      ExplorerRepository(client);

  @override
  ExplorerState build() {
    final state = ExplorerState(
      path: UciPath.empty,
      position: Position.initialPosition(Rule.chess),
      pov: Side.white,
    );
    return state;
  }

  Future<void> fetchExplorer({required String fen}) async {
    state = state.copyWith(explorerResponse: null);
    final response = await ref.withClient(
      (client) => _repository(client).getExplorer(
        fen,
      ),
    );

    state = state.copyWith(explorerResponse: response);
  }

  void onUserMove(Move move) {
    if (state.position.isLegal(move)) {
      final position = state.position.play(move);
      state = state.copyWith(position: position);
      fetchExplorer(fen: position.fen);
    }
  }

  void flipBoard() {
    state = state.copyWith(pov: state.pov.opposite);
  }
}

@freezed
class ExplorerState with _$ExplorerState {
  const ExplorerState._();

  const factory ExplorerState({
    required UciPath path,
    required Position position,
    required Side pov,
    ExplorerResponse? explorerResponse,
  }) = _ExplorerState;
  IMap<String, ISet<String>> get validMoves => algebraicLegalMoves(position);
}
