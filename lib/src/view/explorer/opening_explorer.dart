import 'dart:math' as math;

import 'package:chessground/chessground.dart' as cg;
import 'package:dartchess/dartchess.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/constants.dart';
import 'package:lichess_mobile/src/model/common/id.dart';
import 'package:lichess_mobile/src/model/explorer/explorer_controller.dart';
import 'package:lichess_mobile/src/model/explorer/explorer_game.dart';
import 'package:lichess_mobile/src/model/game/game_repository_providers.dart';
import 'package:lichess_mobile/src/model/settings/board_preferences.dart';
import 'package:lichess_mobile/src/styles/lichess_colors.dart';
import 'package:lichess_mobile/src/utils/chessground_compat.dart';
import 'package:lichess_mobile/src/utils/l10n_context.dart';
import 'package:lichess_mobile/src/utils/navigation.dart';
import 'package:lichess_mobile/src/utils/string.dart';
import 'package:lichess_mobile/src/view/explorer/explorer_settings_screen.dart';
import 'package:lichess_mobile/src/view/game/archived_game_screen.dart';
import 'package:lichess_mobile/src/widgets/adaptive_bottom_sheet.dart';
import 'package:lichess_mobile/src/widgets/bottom_bar_button.dart';
import 'package:lichess_mobile/src/widgets/buttons.dart';

class ExplorerScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(explorerControllerProvider);
    final boardPrefs = ref.watch(boardPreferencesProvider);
    final color = Theme.of(context).platform == TargetPlatform.iOS
        ? CupertinoDynamicColor.resolve(
            CupertinoColors.systemGrey5,
            context,
          )
        : Theme.of(context).colorScheme.secondaryContainer;
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.openingExplorer),
        actions: [
          _ExplorerSettings(),
        ],
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
                      fen: state.currentNode.position.fen,
                      orientation: state.pov.cg,
                      interactableSide: cg.InteractableSide.both,
                      sideToMove: state.currentNode.position.turn.cg,
                      validMoves: state.validMoves,
                      lastMove: state.lastMove?.cg,
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
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Material(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ColoredBox(
                              color: color,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Text(
                                  '${state.opening?.eco ?? ''} ${state.opening?.name ?? ''}',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Table(
                        columnWidths: const <int, TableColumnWidth>{
                          0: IntrinsicColumnWidth(),
                          1: FlexColumnWidth(),
                          2: FractionColumnWidth(0.5),
                        },
                        children: <TableRow>[
                          TableRow(
                            decoration: BoxDecoration(
                              color: color,
                            ),
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Text(
                                  context.l10n.move,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 20.0),
                                child: Text(
                                  context.l10n.games,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                              Text(
                                context.l10n.whiteDrawBlack,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          ...List<TableRow>.generate(
                            state.explorerResponse?.moves.length ?? 0,
                            (index) {
                              final move = state.explorerResponse?.moves[index];
                              return TableRow(
                                children: <Widget>[
                                  TableRowInkWell(
                                    onTap: () {
                                      _fetchExplorer(ref, move!.uci);
                                    },
                                    child: Ink(
                                      color: index.isOdd
                                          ? Theme.of(context)
                                              .colorScheme
                                              .surfaceContainer
                                          : Colors.transparent,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 5.0,
                                        ),
                                        child: Text(
                                          '${move?.san}',
                                          style: const TextStyle(
                                            fontFamily: 'ChessFont',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableRowInkWell(
                                    onTap: () {
                                      _fetchExplorer(ref, move.uci);
                                    },
                                    child: Ink(
                                      color: index.isOdd
                                          ? Theme.of(context)
                                              .colorScheme
                                              .surfaceContainer
                                          : Colors.transparent,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 20),
                                        child: Text(
                                          '${move!.white + move.draws + move.black}'
                                              .localizeNumbers(),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableRowInkWell(
                                    onTap: () {
                                      _fetchExplorer(ref, move.uci);
                                    },
                                    child: Ink(
                                      color: index.isOdd
                                          ? Theme.of(context)
                                              .colorScheme
                                              .surfaceContainer
                                          : Colors.transparent,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5),
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            //TODO find a way to not have this constant
                                            maxHeight: 20,
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
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                      if (state.explorerResponse!.topGames.isNotEmpty)
                        ColoredBox(
                          color: color,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              context.l10n.topGames,
                            ),
                          ),
                        ),
                      GameList(
                        ref: ref,
                        gameslist: state.explorerResponse?.topGames,
                      ),
                      if (state.explorerResponse!.recentGames.isNotEmpty)
                        ColoredBox(
                          color: color,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              context.l10n.recentGames,
                            ),
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
            ),
          _BottomBar(),
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

          return Material(
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
                      orientation: ref.read(explorerControllerProvider).pov,
                    ),
                  );
                });
              },
              child: Ink(
                decoration: BoxDecoration(
                  color: index.isEven
                      ? Colors.transparent
                      : Theme.of(context).colorScheme.surfaceContainer,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${game.white.rating}   ${game.white.name}'),
                        Text('${game.black.rating}   ${game.black.name}'),
                      ],
                    ),
                    const Spacer(),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: ColoredBox(
                        color: game.winner == 'black'
                            ? const Color.fromARGB(255, 21, 21, 21)
                            : game.winner == 'white'
                                ? const Color.fromARGB(255, 230, 230, 230)
                                : LichessColors.grey,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints.tightFor(width: 50),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            child: Center(
                              child: Text(
                                game.winner == 'black'
                                    ? '0-1'
                                    : game.winner == 'white'
                                        ? '1-0'
                                        : '½-½',
                                style: TextStyle(
                                  color: game.winner == 'white'
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(game.month),
                  ],
                ),
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
        return Padding(
          padding: EdgeInsets.only(
            top: constraints.maxHeight * 0.15,
            bottom: constraints.maxHeight * 0.15,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 0,
                  width: constraints.maxWidth * winRateWhite,
                  child: ColoredBox(
                    color: const Color.fromARGB(255, 230, 230, 230),
                    child: Center(
                      child: Text(
                        (winRateWhite > 0.15)
                            ? '${(winRateWhite * 100).toStringAsFixed(0)}%'
                            : '',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: constraints.maxWidth * winRateWhite,
                  width: constraints.maxWidth * drawRate,
                  child: ColoredBox(
                    color: LichessColors.grey,
                    child: Center(
                      child: Text(
                        (drawRate > 0.15)
                            ? '${(drawRate * 100).toStringAsFixed(0)}%'
                            : '',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: constraints.maxWidth * (winRateWhite + drawRate),
                  width: constraints.maxWidth * (1 - winRateWhite - drawRate),
                  child: ColoredBox(
                    color: const Color.fromARGB(255, 21, 21, 21),
                    child: Center(
                      child: Text(
                        (1 - winRateWhite - drawRate > 0.15)
                            ? '${((1 - winRateWhite - drawRate) * 100).toStringAsFixed(0)}%'
                            : '',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BottomBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: (Theme.of(context).platform == TargetPlatform.iOS
          ? CupertinoTheme.of(context).barBackgroundColor
          : Theme.of(context).bottomAppBarTheme.color),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: kBottomBarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: BottomBarButton(
                  label: context.l10n.flipBoard,
                  onTap: () {
                    ref.read(explorerControllerProvider.notifier).flipBoard();
                  },
                  icon: CupertinoIcons.arrow_2_squarepath,
                ),
              ),
              Expanded(
                child: RepeatButton(
                  onLongPress: ref
                          .read(explorerControllerProvider.notifier)
                          .canGoBackward()
                      ? () => _moveBackward(ref)
                      : null,
                  child: BottomBarButton(
                    onTap: ref
                            .read(explorerControllerProvider.notifier)
                            .canGoBackward()
                        ? () => _moveBackward(ref)
                        : null,
                    label: 'Previous',
                    icon: CupertinoIcons.chevron_back,
                    showTooltip: false,
                  ),
                ),
              ),
              Expanded(
                child: RepeatButton(
                  onLongPress: ref
                          .read(explorerControllerProvider.notifier)
                          .canGoForward()
                      ? () => _moveForward(ref)
                      : null,
                  child: BottomBarButton(
                    onTap: ref
                            .read(explorerControllerProvider.notifier)
                            .canGoForward()
                        ? () => _moveForward(ref)
                        : null,
                    label: context.l10n.next,
                    icon: CupertinoIcons.chevron_forward,
                    showTooltip: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _moveBackward(WidgetRef ref) {
    ref.read(explorerControllerProvider.notifier).goToPreviousNode();
  }

  void _moveForward(WidgetRef ref) {
    ref.read(explorerControllerProvider.notifier).goToNextNode();
  }
}

class _ExplorerSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppBarIconButton(
      icon: const Icon(Icons.settings),
      onPressed: () => showAdaptiveBottomSheet<void>(
        context: context,
        isDismissible: true,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => const ExplorerSettingsScreen(),
      ),
      semanticsLabel: context.l10n.settingsSettings,
    );
  }
}
