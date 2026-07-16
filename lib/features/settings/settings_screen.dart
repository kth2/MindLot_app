import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/settings_provider.dart';
import '../../services/ai/ai_config.dart';

/// 設定 — theme, API key, and AI model selection.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
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
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ------- appearance -------
          Text('外觀', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: ThemeMode.values.map((mode) {
                const names = {
                  ThemeMode.system: '跟隨系統',
                  ThemeMode.light: '日殿（淺色）',
                  ThemeMode.dark: '夜殿（深色）',
                };
                return RadioListTile<ThemeMode>(
                  title: Text(names[mode]!),
                  value: mode,
                  groupValue: settings.themeMode,
                  onChanged: (m) {
                    if (m != null) notifier.setThemeMode(m);
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // ------- AI -------
          Text('AI 服務', style: theme.textTheme.titleMedium),
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
                          ? '已設定 ✓'
                          : '請貼上您的 API 金鑰',
                      helperText: '金鑰僅儲存在您的裝置上',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.save_outlined),
                        tooltip: '儲存',
                        onPressed: () {
                          notifier.setApiKey(_apiKeyController.text);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('已儲存 API 金鑰')),
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
                      labelText: '影像辨識模型',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: AiConfig.availableModels
                        .map((m) =>
                            DropdownMenuItem(value: m, child: Text(m)))
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
                      labelText: '解籤模型',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: AiConfig.availableModels
                        .map((m) =>
                            DropdownMenuItem(value: m, child: Text(m)))
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
          Text('關於', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '心籤通 MindLot v0.1.0\n\n'
                '籤詩文化源遠流長，本應用以敬重之心呈現傳統籤詩，'
                '並以 AI 輔助解讀。籤解內容僅供參考與心靈陪伴，'
                '不構成醫療、法律或財務建議；重大決定請諮詢專業人士。\n\n'
                '願您心誠所至，平安喜樂。',
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
