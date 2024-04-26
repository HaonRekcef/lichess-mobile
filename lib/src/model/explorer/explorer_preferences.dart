import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lichess_mobile/src/db/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'explorer_preferences.freezed.dart';
part 'explorer_preferences.g.dart';

const _prefKey = 'explorer.preferences';

@riverpod
class ExplorerPreferences extends _$ExplorerPreferences {
  @override
  ExplorerPrefState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final stored = prefs.getString(_prefKey);
    return stored != null
        ? ExplorerPrefState.fromJson(jsonDecode(stored) as Map<String, dynamic>)
        : ExplorerPrefState.defaults();
  }

  Future<void> saveSelectedRatings(List<int> selectedRatings) async {
    final newState = state.copyWith(selectedRatings: selectedRatings);
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_prefKey, jsonEncode(newState.toJson()));
    state = newState;
  }
}

@Freezed(fromJson: true, toJson: true)
class ExplorerPrefState with _$ExplorerPrefState {
  const factory ExplorerPrefState({
    required List<int> selectedRatings,
    required bool test,
  }) = _ExplorerPrefState;

  factory ExplorerPrefState.defaults() => const ExplorerPrefState(
        selectedRatings: [
          0,
          1000,
          1200,
          1400,
          1600,
          1800,
          2000,
          2200,
          2500,
        ],
        test: false,
      );

  factory ExplorerPrefState.fromJson(Map<String, dynamic> json) =>
      _$ExplorerPrefStateFromJson(json);
}
