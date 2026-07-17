import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindlot/l10n/app_localizations.dart';

// A lightweight smoke test of the localization wiring. (Pumping the whole
// app pulls in SharedPreferences, asset loading and google_fonts, which are
// better covered by the focused unit tests.)
void main() {
  Widget harness(Locale locale) => MaterialApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Builder(
          builder: (context) =>
              Scaffold(body: Text(AppLocalizations.of(context).settings)),
        ),
      );

  testWidgets('renders the English UI string', (tester) async {
    await tester.pumpWidget(harness(const Locale('en')));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('renders the Traditional Chinese UI string', (tester) async {
    await tester.pumpWidget(harness(
        const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')));
    await tester.pumpAndSettle();
    expect(find.text('設定'), findsOneWidget);
  });
}
