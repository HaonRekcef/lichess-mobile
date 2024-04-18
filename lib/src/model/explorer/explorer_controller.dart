import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:lichess_mobile/src/model/common/http.dart';
import 'package:lichess_mobile/src/model/explorer/explorer_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'explorer_controller.freezed.dart';
part 'explorer_controller.g.dart';

@riverpod
class ExplorerController extends _$ExplorerController {
  ExplorerRepository _repository(http.Client client) =>
      ExplorerRepository(client);

  @override
  ExplorerState build() => const ExplorerState(
        fen:
            'rnbqk2r/pppp1pp1/4pn1p/8/1bPP4/2N5/PPQ1PPPP/R1B1KBNR w KQkq - 0 5',
      );
  Future<void> fetchExplorer({required String fen}) async {
    final response = await ref.withClient(
      (client) => _repository(client).getExplorer(
        fen,
      ),
    );

    state = state.copyWith(explorerResponse: response);
  }
}

@freezed
class ExplorerState with _$ExplorerState {
  const ExplorerState._();

  const factory ExplorerState({
    required String fen,
    ExplorerResponse? explorerResponse,
  }) = _ExplorerState;
}
