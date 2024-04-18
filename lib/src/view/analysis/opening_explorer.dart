import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/explorer/explorer_controller.dart';

class ExplorerScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(explorerControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess Explorer'),
      ),
      body: state.explorerResponse == null
          ? const CircularProgressIndicator()
          : Column(
              children: [
                Text('White: ${state.explorerResponse?.white}\n'
                    'Draw: ${state.explorerResponse?.draw}\n'
                    'Black: ${state.explorerResponse?.black}\n'
                    'Opening: ${state.explorerResponse?.opening}\n'
                    'Recent Games: ${state.explorerResponse?.recentGames}\n'
                    'Top Games: ${state.explorerResponse?.topGames}'),
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
            .fetchExplorer(fen: state.fen),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
