import 'dart:math' as math;

import 'package:chessground/chessground.dart' as cg;
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/explorer/explorer_controller.dart';
import 'package:lichess_mobile/src/utils/chessground_compat.dart';
import 'package:lichess_mobile/src/utils/l10n_context.dart';

class ExplorerScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(explorerControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.openingExplorer),
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
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Table(
                  columnWidths: const <int, TableColumnWidth>{
                    0: FlexColumnWidth(0.2),
                    1: FlexColumnWidth(0.3),
                    2: FlexColumnWidth(1),
                  },
                  children: <TableRow>[
                    const TableRow(
                      children: <Widget>[
                        Text('Move',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Games',
                            textAlign: TextAlign.right,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('White/Draw/Black',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ), ...List<TableRow>.generate(
                        state.explorerResponse?.moves.length ?? 0,
                        (index) {
                          final move = state.explorerResponse?.moves[index];
                          return TableRow(
                            children: <Widget>[
                              Text('${move?.san}'),
                              Text(
                                '${move!.white + move.draws + move.black}',
                                textAlign: TextAlign.right,
                              ),
                              Text(
                                ' ${(move.white / (move.white + move.draws + move.black) * 100).toStringAsFixed(1)}% / ${(move.draws / (move.white + move.draws + move.black) * 100).toStringAsFixed(1)}% / ${(move.black / (move.white + move.draws + move.black) * 100).toStringAsFixed(1)}%',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class WinRateBar extends StatelessWidget {
  final double winRateWhite;
  final double drawRate;

  const WinRateBar({
    required this.winRateWhite,
    required this.drawRate,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned.fill(
              child: Container(color: Colors.blueGrey),
            ),
            Positioned(
              left: 0,
              width: constraints.maxWidth * winRateWhite,
              top: 0,
              bottom: 0,
              child: Container(color: Colors.grey),
            ),
            Positioned(
              left: constraints.maxWidth * winRateWhite,
              width: constraints.maxWidth * drawRate,
              top: 0,
              bottom: 0,
              child: Container(color: Colors.white.withOpacity(0.5)),
            ),
          ],
        );
      },
    );
  }
}
