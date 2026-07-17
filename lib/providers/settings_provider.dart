import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/ai/ai_config.dart';

const Object _unset = Object();

class SettingsState {
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.locale, // null = follow the system language
    this.apiKeyOverride = '',
    this.visionModel = AiConfig.defaultVisionModel,
    this.textModel = AiConfig.defaultTextModel,
  });

  final ThemeMode themeMode;

  /// Chosen UI language; null follows the device.
  final Locale? locale;

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
    Object? locale = _unset, // sentinel so null can be assigned explicitly
    String? apiKeyOverride,
    String? visionModel,
    String? textModel,
  }) =>
      SettingsState(
        themeMode: themeMode ?? this.themeMode,
        locale: identical(locale, _unset) ? this.locale : locale as Locale?,
        apiKeyOverride: apiKeyOverride ?? this.apiKeyOverride,
        visionModel: visionModel ?? this.visionModel,
        textModel: textModel ?? this.textModel,
      );
}

/// Serializes a [Locale] to a settings tag and back ('' = system).
String localeToTag(Locale? l) {
  if (l == null) return '';
  if (l.languageCode == 'en') return 'en';
  return l.scriptCode == 'Hans' ? 'zh_Hans' : 'zh_Hant';
}

Locale? localeFromTag(String? tag) => switch (tag) {
      'en' => const Locale('en'),
      'zh_Hant' =>
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
      'zh_Hans' =>
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
      _ => null,
    };

class SettingsNotifier extends Notifier<SettingsState> {
  static const _kTheme = 'mindlot.settings.themeMode';
  static const _kLocale = 'mindlot.settings.locale';
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
      locale: localeFromTag(prefs.getString(_kLocale)),
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

  /// [locale] null follows the device language.
  Future<void> setLocale(Locale? locale) async {
    state = state.copyWith(locale: locale);
    (await SharedPreferences.getInstance())
        .setString(_kLocale, localeToTag(locale));
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
