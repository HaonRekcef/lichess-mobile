import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lichess_mobile/src/model/explorer/explorer_game_speed.dart';
import 'package:lichess_mobile/src/model/explorer/explorer_preferences.dart';
import 'package:lichess_mobile/src/styles/styles.dart';
import 'package:lichess_mobile/src/utils/l10n_context.dart';
import 'package:lichess_mobile/src/widgets/list.dart';
import 'package:lichess_mobile/src/widgets/settings.dart';

class ExplorerSettingsScreen extends ConsumerWidget {
  const ExplorerSettingsScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(explorerPreferencesProvider);
    return DraggableScrollableSheet(
      initialChildSize: .7,
      expand: false,
      snap: true,
      snapSizes: const [.4, .7],
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        children: [
          PlatformListTile(
            title:
                Text(context.l10n.settingsSettings, style: Styles.sectionTitle),
            subtitle: const SizedBox.shrink(),
          ),
          PlatformListTile(
            title: Text(context.l10n.timeControl),
            subtitle: SpeedSelection(),
          ),
          PlatformListTile(
            title: Text(context.l10n.averageElo),
            subtitle: RatingSelection(),
          ),
        ],
      ),
    );
  }
}

class RatingSelection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<int> ratingGroups = [
      0,
      1000,
      1200,
      1400,
      1600,
      1800,
      2000,
      2200,
      2500,
    ];
    final selectedRatings =
        List<int>.from(ref.watch(explorerPreferencesProvider).selectedRatings);

    return Wrap(
      spacing: 5,
      alignment: WrapAlignment.center,
      children: ratingGroups.map((rating) {
        final isSelected = selectedRatings.contains(rating);
        return ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.pressed) || isSelected) {
                  return Theme.of(context).colorScheme.primary;
                }
                return Colors.transparent;
              },
            ),
          ),
          onPressed: () {
            if (isSelected) {
              if (selectedRatings.length > 1) {
                selectedRatings.remove(rating);
              }
            } else {
              selectedRatings.add(rating);
            }
            ref
                .read(explorerPreferencesProvider.notifier)
                .saveSelectedRatings(selectedRatings);
          },
          child: Text(
            rating.toString(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class SpeedSelection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const List<GameSpeed> speedGroups = GameSpeed.values;
    final selectedSpeeds = List<GameSpeed>.from(
      ref.watch(explorerPreferencesProvider).selectedSpeeds,
    );
    return Wrap(
      spacing: 5,
      alignment: WrapAlignment.center,
      children: speedGroups.map((speed) {
        final isSelected = selectedSpeeds.contains(speed);
        return ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.pressed) || isSelected) {
                  return Theme.of(context).colorScheme.primary;
                }
                return Colors.transparent;
              },
            ),
          ),
          onPressed: () {
            if (isSelected) {
              if (selectedSpeeds.length > 1) {
                selectedSpeeds.remove(speed);
              }
            } else {
              selectedSpeeds.add(speed);
            }
            ref
                .read(explorerPreferencesProvider.notifier)
                .saveSelectedSpeeds(selectedSpeeds);
          },
          child: Icon(
            gameSpeedIcons[speed],
            color: Theme.of(context).colorScheme.onSurface,
          ),
        );
      }).toList(),
    );
  }
}
