import 'dart:math' as math;

import 'package:chessground/chessground.dart' as cg;
import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/common/id.dart';
import 'package:lichess_mobile/src/model/explorer/explorer_controller.dart';
import 'package:lichess_mobile/src/model/explorer/explorer_game.dart';
import 'package:lichess_mobile/src/model/game/game_repository_providers.dart';
import 'package:lichess_mobile/src/model/settings/board_preferences.dart';
import 'package:lichess_mobile/src/utils/chessground_compat.dart';
import 'package:lichess_mobile/src/utils/l10n_context.dart';
import 'package:lichess_mobile/src/utils/navigation.dart';
import 'package:lichess_mobile/src/view/game/archived_game_screen.dart';

class ExplorerScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(explorerControllerProvider);
    final boardPrefs = ref.watch(boardPreferencesProvider);
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
                    onMove: (move, {isDrop, isPremove}) =>
                        _fetchExplorer(ref, move.uci),
                    size: minDimension,
                    data: cg.BoardData(
                      fen: state.position.fen,
                      orientation: cg.Side.white,
                      interactableSide: cg.InteractableSide.both,
                      sideToMove: state.position.turn.cg,
                      validMoves: state.validMoves,
                    ),
                    settings: cg.BoardSettings(
                      pieceAssets: boardPrefs.pieceSet.assets,
                      colorScheme: boardPrefs.boardTheme.colors,
                      showValidMoves: boardPrefs.showLegalMoves,
                      showLastMove: boardPrefs.boardHighlights,
                      enableCoordinates: boardPrefs.coordinates,
                      animationDuration: boardPrefs.pieceAnimationDuration,
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
                child: Column(
                  children: [
                    Table(
                      columnWidths: const <int, TableColumnWidth>{
                        0: IntrinsicColumnWidth(),
                        1: FlexColumnWidth(),
                        2: FractionColumnWidth(0.5),
                      },
                      children: <TableRow>[
                        const TableRow(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: 5.0),
                              child: Text(
                                'Move',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 20.0),
                              child: Text(
                                'Games',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              'White/Draw/Black',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        ...List<TableRow>.generate(
                          state.explorerResponse?.moves.length ?? 0,
                          (index) {
                            final move = state.explorerResponse?.moves[index];
                            return TableRow(
                              decoration: BoxDecoration(
                                color: index.isEven
                                    ? const Color.fromARGB(255, 90, 85, 85)
                                        .withOpacity(0.4)
                                    : Colors.transparent,
                              ),
                              children: <Widget>[
                                TableRowInkWell(
                                  onTap: () {
                                    _fetchExplorer(ref, move!.uci);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 5.0,
                                    ),
                                    child: Text(
                                      '${move?.san}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'ChessFont',
                                      ),
                                    ),
                                  ),
                                ),
                                TableRowInkWell(
                                  onTap: () {
                                    _fetchExplorer(ref, move.uci);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: Text(
                                      '${move!.white + move.draws + move.black}',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                TableRowInkWell(
                                  onTap: () {
                                    _fetchExplorer(ref, move.uci);
                                  },
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxHeight: 22,
                                    ),
                                    child: WinRateBar(
                                      winRateWhite: move.white /
                                          (move.white +
                                              move.draws +
                                              move.black),
                                      drawRate: move.draws /
                                          (move.white +
                                              move.draws +
                                              move.black),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Top Games',
                      ),
                    ),
                    GameList(
                      ref: ref,
                      gameslist: state.explorerResponse?.topGames,
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Recent Games',
                      ),
                    ),
                    GameList(
                      ref: ref,
                      gameslist: state.explorerResponse?.recentGames,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _fetchExplorer(WidgetRef ref, String uci) {
    ref
        .read(explorerControllerProvider.notifier)
        .onUserMove(Move.fromUci(uci)!);
  }
}

class GameList extends StatelessWidget {
  const GameList({
    required this.ref,
    required this.gameslist,
  });

  final IList<ExplorerGame>? gameslist;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List<Widget>.generate(
        gameslist?.length ?? 0,
        (index) {
          final game = gameslist?[index];
          final GameId id = GameId(game!.id);

          return Container(
            decoration: BoxDecoration(
              color: index.isEven
                  ? Colors.black
                  : const Color.fromARGB(255, 90, 85, 85).withOpacity(0.4),
            ),
            child: InkWell(
              onTap: () {
                ref
                    .read(
                  archivedGameProvider(id: id).future,
                )
                    .then((game) {
                  pushPlatformRoute(
                    context,
                    builder: (context) => ArchivedGameScreen(
                      gameData: game.data,
                      orientation: Side.white,
                    ),
                  );
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${game.white.rating} ${game.white.name}'),
                      Text('${game.black.rating} ${game.black.name}'),
                    ],
                  ),
                  Text(
                    game.winner == 'black'
                        ? '0-1'
                        : game.winner == 'white'
                            ? '1-0'
                            : '1/2-1/2',
                  ),
                ],
              ),
            ),
          );
        },
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
              child: Container(color: Colors.black),
            ),
            Positioned(
              left: 0,
              width: constraints.maxWidth * winRateWhite,
              top: 0,
              bottom: 0,
              child: Container(color: Colors.white),
            ),
            Positioned(
              left: constraints.maxWidth * winRateWhite,
              width: constraints.maxWidth * drawRate,
              top: 0,
              bottom: 0,
              child: Container(color: Colors.grey),
            ),
          ],
        );
      },
    );
  }
}
