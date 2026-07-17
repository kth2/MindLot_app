import '../services/ai/ai_config.dart';
import 'app_localizations.dart';

/// Localizes an error thrown by the AI layer for display.
///
/// Maps an [AiServiceException]'s machine-readable code to localized text;
/// any other error falls back to the generic "unavailable" message. The
/// exception's technical [AiServiceException.detail] is intentionally not
/// shown to the user (it's for logs), except the HTTP status in serverError.
String aiErrorText(AppLocalizations l10n, Object error) {
  if (error is AiServiceException) {
    return switch (error.code) {
      AiErrorCode.notConfigured => l10n.aiErrNotConfigured,
      AiErrorCode.network => l10n.aiErrNetwork,
      AiErrorCode.rateLimited => l10n.aiErrRateLimited,
      AiErrorCode.invalidKey => l10n.aiErrInvalidKey,
      AiErrorCode.serverError => l10n.aiErrServer(error.detail ?? ''),
      AiErrorCode.emptyResponse => l10n.aiErrEmpty,
    };
  }
  return l10n.aiErrUnknown;
}
