import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lichess_mobile/src/model/engine/evaluation_service.dart';
import 'package:lichess_mobile/src/model/settings/preferences_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'evaluation_preferences.freezed.dart';
part 'evaluation_preferences.g.dart';

/// Preferences for engine evaluation.
///
/// Same preferences are used in various screens where engine evaluation is used:
/// - Analysis screen
/// - Study screen
/// - Broadcast game screen
@Riverpod(keepAlive: true)
class EngineEvaluationPreferences extends _$EngineEvaluationPreferences
    with PreferencesStorage<EngineEvaluationPrefState> {
  // ignore: avoid_public_notifier_properties
  @override
  final prefCategory = PrefCategory.engineEvaluation;

  // ignore: avoid_public_notifier_properties
  @override
  EngineEvaluationPrefState get defaults => EngineEvaluationPrefState.defaults;

  @override
  EngineEvaluationPrefState fromJson(Map<String, dynamic> json) =>
      EngineEvaluationPrefState.fromJson(json);

  @override
  EngineEvaluationPrefState build() {
    return fetch();
  }

  Future<void> toggle() {
    return save(state.copyWith(isEnabled: !state.isEnabled));
  }

  Future<void> setNumEvalLines(int numEvalLines) {
    assert(numEvalLines >= 0 && numEvalLines <= 3);
    return save(state.copyWith(numEvalLines: numEvalLines));
  }

  Future<void> setEngineCores(int numEngineCores) {
    assert(numEngineCores >= 1 && numEngineCores <= maxEngineCores);
    return save(state.copyWith(numEngineCores: numEngineCores));
  }

  Future<void> setEngineSearchTime(Duration engineSearchTime) {
    return save(state.copyWith(engineSearchTime: engineSearchTime));
  }
}

@Freezed(fromJson: true, toJson: true)
class EngineEvaluationPrefState with _$EngineEvaluationPrefState implements Serializable {
  const EngineEvaluationPrefState._();

  const factory EngineEvaluationPrefState({
    /// Whether the engine evaluation is enabled (acts both for local and cloud).
    required bool isEnabled,
    @Assert('numEvalLines >= 0 && numEvalLines <= 3') required int numEvalLines,
    @Assert('numEngineCores >= 1 && numEngineCores <= maxEngineCores') required int numEngineCores,
    @JsonKey(
      defaultValue: _searchTimeDefault,
      fromJson: _searchTimeFromJson,
      toJson: _searchTimeToJson,
    )
    required Duration engineSearchTime,
  }) = _EngineEvaluationPrefState;

  static const defaults = EngineEvaluationPrefState(
    isEnabled: true,
    numEvalLines: 2,
    numEngineCores: 1,
    engineSearchTime: Duration(seconds: 6),
  );

  factory EngineEvaluationPrefState.fromJson(Map<String, dynamic> json) {
    return _$EngineEvaluationPrefStateFromJson(json);
  }

  EvaluationOptions get evaluationOptions =>
      EvaluationOptions(multiPv: numEvalLines, cores: numEngineCores, searchTime: engineSearchTime);
}

Duration _searchTimeDefault() {
  return const Duration(seconds: 6);
}

Duration _searchTimeFromJson(int seconds) {
  return Duration(seconds: seconds);
}

int _searchTimeToJson(Duration duration) {
  return duration.inSeconds;
}

const kAvailableEngineSearchTimes = [
  Duration(seconds: 4),
  Duration(seconds: 6),
  Duration(seconds: 8),
  Duration(seconds: 10),
  Duration(seconds: 12),
  Duration(seconds: 15),
  Duration(seconds: 20),
  Duration(seconds: 30),

  /// Displayed as infinity in the UI.
  Duration(hours: 1),
];
