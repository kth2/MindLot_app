import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mindlot/l10n/ai_error_text.dart';
import 'package:mindlot/l10n/app_localizations.dart';
import 'package:mindlot/services/ai/ai_config.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));

  group('aiErrorText', () {
    test('maps each AiErrorCode to its localized string', () {
      expect(
        aiErrorText(en, const AiServiceException(AiErrorCode.notConfigured)),
        en.aiErrNotConfigured,
      );
      expect(
        aiErrorText(en, const AiServiceException(AiErrorCode.rateLimited)),
        en.aiErrRateLimited,
      );
      expect(
        aiErrorText(en, const AiServiceException(AiErrorCode.invalidKey)),
        en.aiErrInvalidKey,
      );
      expect(
        aiErrorText(en, const AiServiceException(AiErrorCode.network)),
        en.aiErrNetwork,
      );
      expect(
        aiErrorText(en, const AiServiceException(AiErrorCode.emptyResponse)),
        en.aiErrEmpty,
      );
    });

    test('serverError includes the status detail', () {
      final text = aiErrorText(
        en,
        const AiServiceException(AiErrorCode.serverError, detail: '503'),
      );
      expect(text, contains('503'));
    });

    test('non-AI errors fall back to the generic message', () {
      expect(aiErrorText(en, Exception('boom')), en.aiErrUnknown);
      expect(aiErrorText(en, 'some string'), en.aiErrUnknown);
    });

    test('technical detail is not shown for coded errors (except server)', () {
      final text = aiErrorText(
        en,
        const AiServiceException(AiErrorCode.network,
            detail: 'SocketException: connection refused'),
      );
      expect(text, isNot(contains('SocketException')));
    });
  });
}
