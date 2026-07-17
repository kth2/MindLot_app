#!/usr/bin/env python3
# Generates lib/l10n/app_localizations.dart with en / zh-Hant / zh-Hans.
# zh-Hant values are authored below; zh-Hans is derived via OpenCC; en authored.
from opencc import OpenCC
cc = OpenCC('tw2sp')  # Traditional (TW) -> Simplified (with phrase conversion)

# key: (hant, en)   — simple getters
SIMPLE = {
  'appName': ('心籤通', 'MindLot'),
  'homeMotto': ('掌中靈籤，心誠則靈', 'Oracle lots in your palm'),
  'settings': ('設定', 'Settings'),
  'recentRecords': ('近期籤記', 'Recent lots'),
  'viewAll': ('全部 ›', 'All ›'),
  'emptyRecent': ('尚無紀錄，求一支籤開始吧', 'No lots yet — draw one to begin'),
  'appFooter': ('籤詩乃心之明鏡，指引而非定命', 'A lot poem mirrors the heart — guidance, not fate'),
  'ritePhotoTitle': ('拍照辨籤', 'Scan a lot'),
  'ritePhotoSubtitle': ('拍下廟中求得的籤枝或籤詩\nAI 為您辨識並解籤',
                        'Photograph a lot drawn at the temple;\nAI identifies and interprets it'),
  'riteDrawTitle': ('線上求籤', 'Draw a lot'),
  'riteDrawSubtitle': ('默念心中所求，搖籤筒\n誠心抽出一支靈籤',
                       'Hold your question in mind, shake the cylinder,\nand draw a lot in earnest'),
  # photo
  'photoHint': ('請拍攝籤枝或籤詩紙\n盡量正對、光線充足、避免反光',
                'Photograph the lot stick or poem slip\nFace it squarely, good light, no glare'),
  'takePhoto': ('拍照', 'Camera'),
  'gallery': ('相簿', 'Gallery'),
  'analyzing': ('AI 辨識中⋯', 'Recognizing…'),
  'startRecognition': ('開始辨識', 'Recognize'),
  'manualInput': ('手動輸入籤號', 'Enter lot number'),
  'skipToManual': ('略過拍照，直接手動輸入 ›', 'Skip the photo — enter manually ›'),
  'recognitionResult': ('辨識結果', 'Result'),
  'lowConfidenceNote': ('※ 辨識信心較低，請核對籤號是否正確',
                        '※ Low confidence — please verify the lot number'),
  'correct': ('不對，修正', 'Not right — fix'),
  'castConsult': ('擲筊請示', 'Cast the blocks'),
  'skipCastRead': ('不擲筊，直接解籤', 'Skip — read now'),
  'photoNotRecognized': ('照片中未能辨識出籤枝或籤詩，請重拍或改用手動輸入。',
                         'No lot or poem detected — retake the photo or enter it manually.'),
  'poemMatchedNoSet': ('辨識到籤詩但無法對應籤庫，請確認或手動輸入。',
                       'Poem read but no matching lot set — confirm or enter manually.'),
  'matchedByPoem': ('已由籤詩內容比對出此籤', 'Matched by the poem text'),
  'unknownSet': ('未知籤種', 'Unknown lot set'),
  'externalPhotoNote': ('此籤種尚無本地籤庫，將以照片擷取的籤詩進行 AI 解籤',
                        'No local database for this set; AI will interpret the poem read from the photo'),
  'fixNumber': ('修正籤號', 'Fix the number'),
  # camera
  'back': ('返回', 'Back'),
  'torch': ('補光', 'Torch'),
  'retry': ('重試', 'Retry'),
  'noCameraFound': ('找不到可用的相機。', 'No camera available.'),
  'cameraAccessDenied': ('無法使用相機——請在系統設定中允許本 App 存取相機。',
                         'Camera access denied — allow camera access for this app in Settings.'),
  'cameraStartFailed': ('相機啟動失敗，請改用相簿或手動輸入。',
                        'Camera failed to start — use the gallery or manual input.'),
  'captureFailed': ('拍攝失敗，請再試一次', 'Capture failed — try again'),
  # framing
  'frameAlign': ('將籤枝或籤詩對準框內', 'Line up the lot within the frame'),
  'frameHint': ('正對、光線充足、避免反光', 'Square-on, well-lit, no glare'),
  # manual input
  'selectSetFirst': ('請先選擇籤種', 'Choose a lot set first'),
  'lotNumberLabel': ('籤號', 'Lot number'),
  'viewThisLot': ('查閱此籤', 'View this lot'),
  'querying': ('查詢中⋯', 'Looking up…'),
  # draw
  'drawInstruction': ('默念您想請示的事情\n心誠則靈',
                      'Hold in mind what you wish to ask\nSincerity brings clarity'),
  'shaking': ('搖籤中⋯', 'Shaking…'),
  'shake': ('誠心搖籤', 'Shake the cylinder'),
  'youDrew': ('您求得', 'You drew'),
  'shakeAgain': ('再搖一次', 'Shake again'),
  # jiao bei
  'jiaoSacredName': ('聖筊', 'Sacred cast'),
  'jiaoLaughingName': ('笑筊', 'Laughing cast'),
  'jiaoNegativeName': ('陰筊', 'Negative cast'),
  'jiaoSacredMsg': ('神明應允，此籤正是為您而降。',
                    'The deity approves — this lot is meant for you.'),
  'jiaoLaughingMsg': ('神明含笑未答，心念一想，再擲一次。',
                      'The deity smiles without answering — refocus and cast again.'),
  'jiaoNegativeMsg': ('神明搖首，此籤或非所問，可重新求籤。',
                      'The deity declines — this may not be your lot; draw anew.'),
  'drawAnew': ('重新求籤', 'Draw anew'),
  'jiaoAskHint': ('誠心默念所問，擲筊請示神明是否應允此籤',
                  'Focus on your question, then cast to ask if the deity approves this lot'),
  'jiaoCasting': ('擲筊中⋯', 'Casting…'),
  'jiaoRead': ('恭請解籤', 'Read the lot'),
  'cast': ('擲筊', 'Cast'),
  'castAgain': ('再擲一次', 'Cast again'),
  'readAnyway': ('仍要解籤', 'Read anyway'),
  'threeSacred': ('連得三聖筊，心誠格天！', 'Three sacred casts — your sincerity moves heaven!'),
  # lot detail
  'shareThisLot': ('分享此籤', 'Share this lot'),
  'favorite': ('收藏', 'Favorite'),
  'externalAiNote': ('※ 此籤種尚未收錄本地籤庫，以下解讀由 AI 依籤詩原文推敲。',
                     '※ No local database for this set; the reading below is AI-inferred from the poem.'),
  'sectionPlain': ('白話淺釋', 'In plain words'),
  'sectionAllusion': ('典故', 'Allusion'),
  'sectionShengyi': ('聖意', 'Oracle notes'),
  'sectionJieyue': ('解曰', 'Interpretation'),
  'sectionAspects': ('六事指引', 'Six aspects'),
  'askReadingTitle': ('請示解籤', 'Ask for a reading'),
  'askReadingSubtitle': ('告訴解籤師您的心事，獲得專屬於您的籤解',
                         'Share what is on your mind for a reading tailored to you'),
  'questionHint': ('例如：我正在考慮換工作，這個時機合適嗎？',
                   'e.g. I am thinking of changing jobs — is now a good time?'),
  'interpreting': ('解籤師沉思中⋯', 'The interpreter is reflecting…'),
  'askAi': ('請 AI 解籤', 'Ask AI to interpret'),
  'interpreterVoice': ('解籤師的話', 'From the interpreter'),
  'readingDisclaimer': ('籤解僅供參考，重大決定請諮詢專業意見',
                        'Readings are for reflection only; consult a professional for major decisions'),
  # aspects
  'aspectCareer': ('事業', 'Career'),
  'aspectLove': ('感情', 'Love'),
  'aspectWealth': ('財運', 'Wealth'),
  'aspectHealth': ('健康', 'Health'),
  'aspectStudy': ('學業', 'Study'),
  'aspectTravel': ('出行', 'Travel'),
  # history
  'historyTitle': ('籤記', 'History'),
  'tabAll': ('全部', 'All'),
  'emptyFavorites': ('尚無收藏的籤\n在籤詩頁點擊 ♥ 即可收藏',
                     'No favorites yet\nTap ♥ on a lot to save it'),
  'emptyHistory': ('尚無籤記\n求一支籤開始吧', 'No lots yet\nDraw one to begin'),
  'sourcePhoto': ('拍照', 'Photo'),
  'sourceDraw': ('線上', 'Draw'),
  'sourceManual': ('手動', 'Manual'),
  # settings
  'appearance': ('外觀', 'Appearance'),
  'themeSystem': ('跟隨系統', 'System default'),
  'themeLight': ('日殿（淺色）', 'Day shrine (light)'),
  'themeDark': ('夜殿（深色）', 'Night shrine (dark)'),
  'language': ('語言', 'Language'),
  'aiService': ('AI 服務', 'AI service'),
  'apiKeySet': ('已設定 ✓', 'Set ✓'),
  'apiKeyHint': ('請貼上您的 API 金鑰', 'Paste your API key'),
  'apiKeyHelper': ('金鑰僅儲存在您的裝置上', 'The key is stored only on your device'),
  'save': ('儲存', 'Save'),
  'apiKeySaved': ('已儲存 API 金鑰', 'API key saved'),
  'visionModel': ('影像辨識模型', 'Vision model'),
  'textModel': ('解籤模型', 'Interpretation model'),
  'about': ('關於', 'About'),
  'aboutBody': ('籤詩文化源遠流長，本應用以敬重之心呈現傳統籤詩，'
               '並以 AI 輔助解讀。籤解內容僅供參考與心靈陪伴，'
               '不構成醫療、法律或財務建議；重大決定請諮詢專業人士。\n\n'
               '願您心誠所至，平安喜樂。',
               'Divination lots carry a long heritage. MindLot presents these '
               'traditional poems with respect and adds AI-assisted readings. '
               'Interpretations are for reflection and comfort only — they are '
               'not medical, legal, or financial advice; consult a professional '
               'for important decisions.\n\nMay your sincerity be met with peace and joy.'),
  # share
  'shareImage': ('分享圖片', 'Share image'),
  'preparing': ('準備中⋯', 'Preparing…'),
  'shareFailed': ('分享失敗，請再試一次', 'Sharing failed — try again'),
  # AI service errors
  'aiErrNotConfigured': ('尚未設定 API 金鑰，請至「設定」輸入 Gemini API Key。',
                         'No API key set — add your Gemini API key in Settings.'),
  'aiErrNetwork': ('網路連線失敗，請稍後再試。', 'Network error — please try again shortly.'),
  'aiErrRateLimited': ('請求過於頻繁，請稍候片刻再試。',
                       'Too many requests — please wait a moment and retry.'),
  'aiErrInvalidKey': ('API 金鑰無效或權限不足，請至「設定」檢查。',
                      'Invalid API key or insufficient permission — check Settings.'),
  'aiErrEmpty': ('AI 未能產生有效回應，請重試。', 'The AI returned no usable response — please retry.'),
  'aiErrUnknown': ('AI 服務暫時無法使用，請稍後再試。',
                   'The AI service is temporarily unavailable — please try again later.'),
}

# key: (params_dart_sig, hant_template, en_template)  — method getters ($param interpolation)
METHODS = {
  'photoLoadError': ('Object e', '無法取得照片：$e', 'Could not load photo: $e'),
  'cameraOpenError': ('Object e', '無法開啟相機：$e', 'Could not open camera: $e'),
  'confidence': ('int p', '信心 $p%', 'Confidence $p%'),
  'cameraStartFailedCode': ('String code', '相機啟動失敗（$code）。', 'Camera failed to start ($code).'),
  'allusionTitle': ('String title', '籤題：$title', 'Allusion: $title'),
  'noteLine': ('String note', '※ $note', '※ $note'),
  'numberRangeError': ('int max', '請輸入 1–$max 之間的籤號', 'Enter a number between 1 and $max'),
  'numberRangeHint': ('int max', '1 – $max', '1 – $max'),
  'lotNotYetAdded': ('int number', '第 $number 籤的資料尚未收錄，敬請期待後續更新。',
                     'Lot $number is not in the database yet — coming in a future update.'),
  'setLoadError': ('Object e', '籤庫載入失敗：$e', 'Failed to load lot data: $e'),
  'loadError': ('Object e', '載入失敗：$e', 'Failed to load: $e'),
  'questionPrefix': ('String q', '問：$q', 'Q: $q'),
  'jiaoAsk': ('String set, String label', '求得「$set・$label」', 'Drew “$set・$label”'),
  'aiErrServer': ('String code', 'AI 服務暫時無法使用（$code）。',
                  'The AI service is temporarily unavailable ($code).'),
}

def dq(s):
    return '"' + s.replace('\\', '\\\\').replace('"', '\\"').replace('\n', '\\n') + '"'

def block(variant_index):
    # variant_index: 0 hant, 1 en ; hans derived from hant
    lines = []
    for k, v in SIMPLE.items():
        hant, en = v
        val = en if variant_index == 1 else (cc.convert(hant) if variant_index == 2 else hant)
        lines.append(f'  @override\n  String get {k} => {dq(val)};')
    for k, (sig, hant, en) in METHODS.items():
        tmpl = en if variant_index == 1 else (cc.convert(hant) if variant_index == 2 else hant)
        lines.append(f'  @override\n  String {k}({sig}) => {dq(tmpl)};')
    return '\n'.join(lines)

simple_getters = '\n'.join(f'  String get {k};' for k in SIMPLE)
method_getters = '\n'.join(f'  String {k}({sig});' for k, (sig, _, _) in METHODS.items())

out = f'''// GENERATED — do not edit by hand. Source: tool/gen_l10n.py (see repo history).
// Hand-rolled localization (no gen_l10n codegen). en / zh-Hant / zh-Hans.
// ignore_for_file: prefer_single_quotes, lines_longer_than_80_chars
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// App UI strings. Lot content (poems, interpretations) stays in its source
/// language; only interface chrome is localized here.
abstract class AppLocalizations {{
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

{simple_getters}

{method_getters}

  /// Localized aspect label for a canonical aspect key.
  String aspectName(String key) => switch (key) {{
        'career' => aspectCareer,
        'love' => aspectLove,
        'wealth' => aspectWealth,
        'health' => aspectHealth,
        'study' => aspectStudy,
        'travel' => aspectTravel,
        _ => key,
      }};
}}

class AppLocalizationsEn extends AppLocalizations {{
{block(1)}
}}

class AppLocalizationsZhHant extends AppLocalizations {{
{block(0)}
}}

class AppLocalizationsZhHans extends AppLocalizations {{
{block(2)}
}}

AppLocalizations lookupAppLocalizations(Locale locale) {{
  if (locale.languageCode == 'zh') {{
    if (locale.scriptCode == 'Hans' ||
        locale.countryCode == 'CN' ||
        locale.countryCode == 'SG' ||
        locale.countryCode == 'MY') {{
      return AppLocalizationsZhHans();
    }}
    return AppLocalizationsZhHant();
  }}
  return AppLocalizationsEn();
}}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {{
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'en' || locale.languageCode == 'zh';

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}}
'''

import os
os.makedirs('/home/user/MindLot_app/lib/l10n', exist_ok=True)
open('/home/user/MindLot_app/lib/l10n/app_localizations.dart', 'w').write(out)
print('wrote app_localizations.dart:', len(out), 'bytes;', len(SIMPLE), 'simple +', len(METHODS), 'methods')
