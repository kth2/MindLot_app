import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/settings_provider.dart';
import '../../services/ai/ai_config.dart';

/// 設定 — theme, language, API key, and AI model selection.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

/// A locale option; null means "follow the system".
class _LangOption {
  const _LangOption(this.locale, this.label);
  final Locale? locale;
  final String label; // shown in its own script, not localized
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _apiKeyController;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(
      text: ref.read(settingsProvider).apiKeyOverride,
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    final langOptions = <_LangOption>[
      _LangOption(null, l10n.themeSystem),
      const _LangOption(Locale('en'), 'English'),
      const _LangOption(
          Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
          '繁體中文'),
      const _LangOption(
          Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
          '简体中文'),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ------- appearance -------
          Text(l10n.appearance, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: RadioGroup<ThemeMode>(
              groupValue: settings.themeMode,
              onChanged: (m) {
                if (m != null) notifier.setThemeMode(m);
              },
              child: Column(
                children: ThemeMode.values.map((mode) {
                  final label = switch (mode) {
                    ThemeMode.system => l10n.themeSystem,
                    ThemeMode.light => l10n.themeLight,
                    ThemeMode.dark => l10n.themeDark,
                  };
                  return RadioListTile<ThemeMode>(
                    title: Text(label),
                    value: mode,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ------- language -------
          Text(l10n.language, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: RadioGroup<String>(
              groupValue: localeToTag(settings.locale),
              onChanged: (tag) => notifier.setLocale(localeFromTag(tag)),
              child: Column(
                children: langOptions.map((opt) {
                  return RadioListTile<String>(
                    title: Text(opt.label),
                    value: localeToTag(opt.locale),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ------- AI -------
          Text(l10n.aiService, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _apiKeyController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Gemini API Key',
                      hintText: settings.aiConfig.isConfigured
                          ? l10n.apiKeySet
                          : l10n.apiKeyHint,
                      helperText: l10n.apiKeyHelper,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.save_outlined),
                        tooltip: l10n.save,
                        onPressed: () {
                          notifier.setApiKey(_apiKeyController.text);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.apiKeySaved)),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: settings.visionModel,
                    decoration: InputDecoration(
                      labelText: l10n.visionModel,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: AiConfig.availableModels
                        .map((m) =>
                            DropdownMenuItem(value: m, child: Text(AiConfig.modelLabel(m))))
                        .toList(),
                    onChanged: (m) {
                      if (m != null) notifier.setVisionModel(m);
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    // ignore: deprecated_member_use
                    value: settings.textModel,
                    decoration: InputDecoration(
                      labelText: l10n.textModel,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: AiConfig.availableModels
                        .map((m) =>
                            DropdownMenuItem(value: m, child: Text(AiConfig.modelLabel(m))))
                        .toList(),
                    onChanged: (m) {
                      if (m != null) notifier.setTextModel(m);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ------- about -------
          Text(l10n.about, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '${l10n.appName} · MindLot v0.1.0\n\n${l10n.aboutBody}',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
