import 'package:chessground/chessground.dart';
import 'package:dartchess/dartchess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/constants.dart';
import 'package:lichess_mobile/src/model/settings/board_preferences.dart';
import 'package:lichess_mobile/src/widgets/evaluation_bar.dart';

/// A board thumbnail widget
class BoardThumbnail extends ConsumerStatefulWidget {
  const BoardThumbnail({
    required this.size,
    required this.orientation,
    required this.fen,
    this.showEvaluationBar = false,
    this.whiteWinningChances,
    this.header,
    this.footer,
    this.lastMove,
    this.onTap,
  });

  const BoardThumbnail.loading({
    required this.size,
    this.header,
    this.footer,
    this.showEvaluationBar = false,
  })  : whiteWinningChances = null,
        orientation = Side.white,
        fen = kInitialFEN,
        lastMove = null,
        onTap = null;

  /// Size of the board.
  final double size;

  /// Side by which the board is oriented.
  final Side orientation;

  /// FEN string describing the position of the board.
  final String fen;

  /// Whether the evaluation bar should be shown.
  final bool showEvaluationBar;

  /// Winning chances from the white pov for the given fen.
  final double? whiteWinningChances;

  /// Last move played, used to highlight corresponding squares.
  final Move? lastMove;

  /// Show a header above the board. Typically a [Text] widget.
  final Widget? header;

  /// Show a footer above the board. Typically a [Text] widget.
  final Widget? footer;

  final GestureTapCallback? onTap;

  @override
  _BoardThumbnailState createState() => _BoardThumbnailState();
}

class _BoardThumbnailState extends ConsumerState<BoardThumbnail> {
  double scale = 1.0;

  void _onTapDown() {
    if (widget.onTap == null) return;
    setState(() => scale = 0.98);
  }

  void _onTapCancel() {
    if (widget.onTap == null) return;
    setState(() => scale = 1.00);
  }

  @override
  Widget build(BuildContext context) {
    final boardPrefs = ref.watch(boardPreferencesProvider);

    final board = Chessboard.fixed(
      size: widget.size,
      fen: widget.fen,
      orientation: widget.orientation,
      lastMove: widget.lastMove as NormalMove?,
      settings: ChessboardSettings(
        enableCoordinates: false,
        borderRadius: (widget.showEvaluationBar)
            ? const BorderRadius.only(
                topLeft: Radius.circular(4.0),
                bottomLeft: Radius.circular(4.0),
              )
            : const BorderRadius.all(Radius.circular(4.0)),
        boxShadow: (widget.showEvaluationBar) ? [] : boardShadows,
        animationDuration: const Duration(milliseconds: 150),
        pieceAssets: boardPrefs.pieceSet.assets,
        colorScheme: boardPrefs.boardTheme.colors,
      ),
    );

    final maybeTappableBoard = widget.onTap != null
        ? GestureDetector(
            onTap: widget.onTap,
            onTapDown: (_) => _onTapDown(),
            onTapCancel: _onTapCancel,
            onTapUp: (_) => _onTapCancel(),
            child: AnimatedScale(
              scale: scale,
              duration: const Duration(milliseconds: 100),
              child: board,
            ),
          )
        : board;

    final boardWithMaybeEvalBar = widget.showEvaluationBar
        ? DecoratedBox(
            decoration: BoxDecoration(boxShadow: boardShadows),
            child: Row(
              children: [
                Expanded(child: maybeTappableBoard),
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(4.0),
                    bottomRight: Radius.circular(4.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: (widget.whiteWinningChances != null)
                      ? EvaluationBar(
                          height: widget.size,
                          whiteWinnigChances: widget.whiteWinningChances!,
                        )
                      : SizedBox(
                          height: widget.size,
                          width: widget.size * evaluationBarAspectRatio,
                          child:
                              ColoredBox(color: Colors.grey.withOpacity(0.6)),
                        ),
                ),
              ],
            ),
          )
        : maybeTappableBoard;

    return widget.header != null || widget.footer != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.header != null) widget.header!,
              boardWithMaybeEvalBar,
              if (widget.footer != null) widget.footer!,
            ],
          )
        : boardWithMaybeEvalBar;
  }
}
