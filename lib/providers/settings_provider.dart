import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/ai/ai_config.dart';

class SettingsState {
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.apiKeyOverride = '',
    this.visionModel = AiConfig.defaultVisionModel,
    this.textModel = AiConfig.defaultTextModel,
  });

  final ThemeMode themeMode;

  /// API key entered in Settings; overrides the build-time --dart-define.
  final String apiKeyOverride;
  final String visionModel;
  final String textModel;

  /// Effective config: in-app key wins, else build-time key.
  AiConfig get aiConfig => AiConfig(
        apiKey:
            apiKeyOverride.isNotEmpty ? apiKeyOverride : AiConfig.envApiKey,
        visionModel: visionModel,
        textModel: textModel,
      );

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? apiKeyOverride,
    String? visionModel,
    String? textModel,
  }) =>
      SettingsState(
        themeMode: themeMode ?? this.themeMode,
        apiKeyOverride: apiKeyOverride ?? this.apiKeyOverride,
        visionModel: visionModel ?? this.visionModel,
        textModel: textModel ?? this.textModel,
      );
}

class SettingsNotifier extends Notifier<SettingsState> {
  static const _kTheme = 'mindlot.settings.themeMode';
  static const _kApiKey = 'mindlot.settings.apiKey';
  static const _kVisionModel = 'mindlot.settings.visionModel';
  static const _kTextModel = 'mindlot.settings.textModel';

  @override
  SettingsState build() {
    _load();
    return const SettingsState();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      themeMode: ThemeMode.values.firstWhere(
        (m) => m.name == prefs.getString(_kTheme),
        orElse: () => ThemeMode.system,
      ),
      apiKeyOverride: prefs.getString(_kApiKey) ?? '',
      visionModel:
          prefs.getString(_kVisionModel) ?? AiConfig.defaultVisionModel,
      textModel: prefs.getString(_kTextModel) ?? AiConfig.defaultTextModel,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    (await SharedPreferences.getInstance()).setString(_kTheme, mode.name);
  }

  Future<void> setApiKey(String key) async {
    state = state.copyWith(apiKeyOverride: key.trim());
    (await SharedPreferences.getInstance())
        .setString(_kApiKey, key.trim());
  }

  Future<void> setVisionModel(String model) async {
    state = state.copyWith(visionModel: model);
    (await SharedPreferences.getInstance()).setString(_kVisionModel, model);
  }

  Future<void> setTextModel(String model) async {
    state = state.copyWith(textModel: model);
    (await SharedPreferences.getInstance()).setString(_kTextModel, model);
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
