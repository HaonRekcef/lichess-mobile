import 'dart:async';
import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:lichess_mobile/src/model/common/http.dart';
import 'package:lichess_mobile/src/model/common/node.dart';
import 'package:lichess_mobile/src/model/common/uci.dart';
import 'package:lichess_mobile/src/model/explorer/explorer_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'explorer_controller.freezed.dart';
part 'explorer_controller.g.dart';

@riverpod
class ExplorerController extends _$ExplorerController {
  ExplorerController() {
    Future.microtask(() => fetchExplorer(fen: state.root.position.fen));
  }
  ExplorerRepository _repository(http.Client client) =>
      ExplorerRepository(client);

  @override
  ExplorerState build() {
    final root = Root(position: Position.initialPosition(Rule.chess));
    final state = ExplorerState(
      path: UciPath.empty,
      pov: Side.white,
      root: root,
      currentNode: root,
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
    if (!state.currentNode.position.isLegal(move)) return;
    final (newPath, _) = state.root.addMoveAt(state.path, move);

    if (newPath != null) {
      state.root.promoteAt(newPath, toMainline: true);
      _setPath(newPath);
    }
    fetchExplorer(fen: state.currentNode.position.fen);
  }

  void flipBoard() {
    state = state.copyWith(pov: state.pov.opposite);
  }

  bool canGoForward() {
    return state.currentNode.children.isNotEmpty;
  }

  bool canGoBackward() {
    return state.currentNode != state.root;
  }

  void goToNextNode() {
    if (state.currentNode.children.isEmpty) return;
    _setPath(state.path + state.currentNode.children.first.id);
    fetchExplorer(fen: state.currentNode.position.fen);
  }

  void goToPreviousNode() {
    _setPath(state.path.penultimate);
    fetchExplorer(fen: state.currentNode.position.fen);
  }

  void _setPath(UciPath path) {
    state = state.copyWith(path: path, currentNode: state.root.nodeAt(path));
  }
}

@freezed
class ExplorerState with _$ExplorerState {
  const ExplorerState._();

  const factory ExplorerState({
    required UciPath path,
    required Side pov,
    required Root root,
    required Node currentNode,
    ExplorerResponse? explorerResponse,
  }) = _ExplorerState;
  IMap<String, ISet<String>> get validMoves =>
      algebraicLegalMoves(currentNode.position);
}
