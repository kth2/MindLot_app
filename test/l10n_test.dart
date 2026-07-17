import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindlot/l10n/app_localizations.dart';

void main() {
  group('AppLocalizations', () {
    test('resolves the three scripts distinctly', () {
      final en = lookupAppLocalizations(const Locale('en'));
      final hant = lookupAppLocalizations(
          const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'));
      final hans = lookupAppLocalizations(
          const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'));

      expect(en, isA<AppLocalizationsEn>());
      expect(hant, isA<AppLocalizationsZhHant>());
      expect(hans, isA<AppLocalizationsZhHans>());

      expect(en.settings, 'Settings');
      expect(hant.settings, '設定');
      expect(hans.settings, '设置');
    });

    test('zh country codes without script map to the right script', () {
      expect(lookupAppLocalizations(const Locale('zh', 'CN')),
          isA<AppLocalizationsZhHans>());
      expect(lookupAppLocalizations(const Locale('zh', 'TW')),
          isA<AppLocalizationsZhHant>());
    });

    test('unknown locale falls back to English', () {
      expect(lookupAppLocalizations(const Locale('fr')),
          isA<AppLocalizationsEn>());
    });

    test('parameterized strings interpolate', () {
      final en = lookupAppLocalizations(const Locale('en'));
      expect(en.confidence(87), 'Confidence 87%');
      expect(en.numberRangeError(60), contains('60'));
    });

    test('aspectName maps canonical keys', () {
      final en = lookupAppLocalizations(const Locale('en'));
      final hant = lookupAppLocalizations(
          const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'));
      expect(en.aspectName('career'), 'Career');
      expect(hant.aspectName('love'), '感情');
      expect(en.aspectName('unknown'), 'unknown'); // graceful passthrough
    });

    test('the delegate supports en and zh only', () {
      const d = AppLocalizations.delegate;
      expect(d.isSupported(const Locale('en')), isTrue);
      expect(d.isSupported(const Locale('zh')), isTrue);
      expect(d.isSupported(const Locale('fr')), isFalse);
    });
  });
}
