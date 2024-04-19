import 'dart:math' as math;

import 'package:chessground/chessground.dart' as cg;
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/explorer/explorer_controller.dart';
import 'package:lichess_mobile/src/utils/chessground_compat.dart';

class ExplorerScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(explorerControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess Explorer'),
      ),
      body: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final minDimension =
                  math.min(constraints.maxWidth, constraints.maxHeight);
              return Column(
                children: [
                  cg.Board(
                    onMove: (move, {isDrop, isPremove}) => ref
                        .read(explorerControllerProvider.notifier)
                        .onUserMove(Move.fromUci(move.uci)!),
                    size: minDimension,
                    data: cg.BoardData(
                      fen: state.position.fen,
                      orientation: cg.Side.white,
                      interactableSide: cg.InteractableSide.both,
                      sideToMove: state.position.turn.cg,
                      validMoves: state.validMoves,
                    ),
                  ),
                ],
              );
            },
          ),
          if (state.explorerResponse == null)
            const CircularProgressIndicator()
          else
            Text('White: ${state.explorerResponse?.white}\n'
                'Draw: ${state.explorerResponse?.draw}\n'
                'Black: ${state.explorerResponse?.black}\n'
                'Opening: ${state.explorerResponse?.opening}\n'),
          Expanded(
            child: ListView.builder(
              itemCount: state.explorerResponse?.moves.length ?? 0,
              itemBuilder: (context, index) {
                final move = state.explorerResponse?.moves[index];
                return ListTile(
                  title: Text('Move: ${move?.san}'),
                  subtitle: Text('White: ${move?.white}\n'
                      'Draw: ${move?.draws}\n'
                      'Black: ${move?.black}'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref
            .read(explorerControllerProvider.notifier)
            .fetchExplorer(fen: state.position.fen),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
