import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'providers/settings_provider.dart';

class MindLotApp extends ConsumerWidget {
  const MindLotApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(settingsProvider.select((s) => s.themeMode));
    final locale = ref.watch(settingsProvider.select((s) => s.locale));

    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Match a device locale like zh-TW / zh-CN to the right script.
      localeResolutionCallback: (device, supported) {
        if (device == null) return const Locale('en');
        for (final l in supported) {
          if (l.languageCode == device.languageCode &&
              (l.scriptCode == null ||
                  l.scriptCode == device.scriptCode ||
                  _zhScriptFor(device) == l.scriptCode)) {
            return l;
          }
        }
        return device.languageCode == 'zh'
            ? const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
            : const Locale('en');
      },
      // Honour the device font-size setting, but cap it: this UI has wide
      // letter-spacing and long localized strings, and beyond ~1.3x rows
      // start to overflow on narrow phones.
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(maxScaleFactor: 1.3),
          ),
          child: child!,
        );
      },
      routerConfig: appRouter,
    );
  }

  /// Infer Han script from a zh device locale that omits it (e.g. zh-CN → Hans).
  static String? _zhScriptFor(Locale l) {
    if (l.languageCode != 'zh') return null;
    if (l.scriptCode != null) return l.scriptCode;
    return switch (l.countryCode) {
      'CN' || 'SG' || 'MY' => 'Hans',
      _ => 'Hant',
    };
  }
}
