// GENERATED — do not edit by hand. Source: tool/gen_l10n.py (see repo history).
// Hand-rolled localization (no gen_l10n codegen). en / zh-Hant / zh-Hans.
// ignore_for_file: prefer_single_quotes, lines_longer_than_80_chars
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// App UI strings. Lot content (poems, interpretations) stays in its source
/// language; only interface chrome is localized here.
abstract class AppLocalizations {
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  String get appName;
  String get homeMotto;
  String get settings;
  String get recentRecords;
  String get viewAll;
  String get emptyRecent;
  String get appFooter;
  String get ritePhotoTitle;
  String get ritePhotoSubtitle;
  String get riteDrawTitle;
  String get riteDrawSubtitle;
  String get photoHint;
  String get takePhoto;
  String get gallery;
  String get analyzing;
  String get startRecognition;
  String get manualInput;
  String get skipToManual;
  String get recognitionResult;
  String get lowConfidenceNote;
  String get correct;
  String get castConsult;
  String get skipCastRead;
  String get photoNotRecognized;
  String get poemMatchedNoSet;
  String get matchedByPoem;
  String get unknownSet;
  String get externalPhotoNote;
  String get fixNumber;
  String get back;
  String get torch;
  String get retry;
  String get noCameraFound;
  String get cameraAccessDenied;
  String get cameraStartFailed;
  String get captureFailed;
  String get frameAlign;
  String get frameHint;
  String get selectSetFirst;
  String get lotNumberLabel;
  String get viewThisLot;
  String get querying;
  String get drawInstruction;
  String get shaking;
  String get shake;
  String get youDrew;
  String get shakeAgain;
  String get jiaoSacredName;
  String get jiaoLaughingName;
  String get jiaoNegativeName;
  String get jiaoSacredMsg;
  String get jiaoLaughingMsg;
  String get jiaoNegativeMsg;
  String get drawAnew;
  String get jiaoAskHint;
  String get jiaoCasting;
  String get jiaoRead;
  String get cast;
  String get castAgain;
  String get readAnyway;
  String get threeSacred;
  String get shareThisLot;
  String get favorite;
  String get externalAiNote;
  String get sectionPlain;
  String get sectionAllusion;
  String get sectionShengyi;
  String get sectionJieyue;
  String get sectionAspects;
  String get askReadingTitle;
  String get askReadingSubtitle;
  String get questionHint;
  String get interpreting;
  String get askAi;
  String get interpreterVoice;
  String get readingDisclaimer;
  String get aspectCareer;
  String get aspectLove;
  String get aspectWealth;
  String get aspectHealth;
  String get aspectStudy;
  String get aspectTravel;
  String get historyTitle;
  String get tabAll;
  String get emptyFavorites;
  String get emptyHistory;
  String get sourcePhoto;
  String get sourceDraw;
  String get sourceManual;
  String get appearance;
  String get themeSystem;
  String get themeLight;
  String get themeDark;
  String get language;
  String get aiService;
  String get apiKeySet;
  String get apiKeyHint;
  String get apiKeyHelper;
  String get save;
  String get apiKeySaved;
  String get visionModel;
  String get textModel;
  String get about;
  String get aboutBody;
  String get shareImage;
  String get preparing;
  String get shareFailed;

  String photoLoadError(Object e);
  String cameraOpenError(Object e);
  String confidence(int p);
  String cameraStartFailedCode(String code);
  String allusionTitle(String title);
  String noteLine(String note);
  String numberRangeError(int max);
  String numberRangeHint(int max);
  String lotNotYetAdded(int number);
  String setLoadError(Object e);
  String loadError(Object e);
  String questionPrefix(String q);
  String jiaoAsk(String set, String label);

  /// Localized aspect label for a canonical aspect key.
  String aspectName(String key) => switch (key) {
        'career' => aspectCareer,
        'love' => aspectLove,
        'wealth' => aspectWealth,
        'health' => aspectHealth,
        'study' => aspectStudy,
        'travel' => aspectTravel,
        _ => key,
      };
}

class AppLocalizationsEn extends AppLocalizations {
  @override
  String get appName => "MindLot";
  @override
  String get homeMotto => "Oracle lots in your palm";
  @override
  String get settings => "Settings";
  @override
  String get recentRecords => "Recent lots";
  @override
  String get viewAll => "All ›";
  @override
  String get emptyRecent => "No lots yet — draw one to begin";
  @override
  String get appFooter => "A lot poem mirrors the heart — guidance, not fate";
  @override
  String get ritePhotoTitle => "Scan a lot";
  @override
  String get ritePhotoSubtitle => "Photograph a lot drawn at the temple;\nAI identifies and interprets it";
  @override
  String get riteDrawTitle => "Draw a lot";
  @override
  String get riteDrawSubtitle => "Hold your question in mind, shake the cylinder,\nand draw a lot in earnest";
  @override
  String get photoHint => "Photograph the lot stick or poem slip\nFace it squarely, good light, no glare";
  @override
  String get takePhoto => "Camera";
  @override
  String get gallery => "Gallery";
  @override
  String get analyzing => "Recognizing…";
  @override
  String get startRecognition => "Recognize";
  @override
  String get manualInput => "Enter lot number";
  @override
  String get skipToManual => "Skip the photo — enter manually ›";
  @override
  String get recognitionResult => "Result";
  @override
  String get lowConfidenceNote => "※ Low confidence — please verify the lot number";
  @override
  String get correct => "Not right — fix";
  @override
  String get castConsult => "Cast the blocks";
  @override
  String get skipCastRead => "Skip — read now";
  @override
  String get photoNotRecognized => "No lot or poem detected — retake the photo or enter it manually.";
  @override
  String get poemMatchedNoSet => "Poem read but no matching lot set — confirm or enter manually.";
  @override
  String get matchedByPoem => "Matched by the poem text";
  @override
  String get unknownSet => "Unknown lot set";
  @override
  String get externalPhotoNote => "No local database for this set; AI will interpret the poem read from the photo";
  @override
  String get fixNumber => "Fix the number";
  @override
  String get back => "Back";
  @override
  String get torch => "Torch";
  @override
  String get retry => "Retry";
  @override
  String get noCameraFound => "No camera available.";
  @override
  String get cameraAccessDenied => "Camera access denied — allow camera access for this app in Settings.";
  @override
  String get cameraStartFailed => "Camera failed to start — use the gallery or manual input.";
  @override
  String get captureFailed => "Capture failed — try again";
  @override
  String get frameAlign => "Line up the lot within the frame";
  @override
  String get frameHint => "Square-on, well-lit, no glare";
  @override
  String get selectSetFirst => "Choose a lot set first";
  @override
  String get lotNumberLabel => "Lot number";
  @override
  String get viewThisLot => "View this lot";
  @override
  String get querying => "Looking up…";
  @override
  String get drawInstruction => "Hold in mind what you wish to ask\nSincerity brings clarity";
  @override
  String get shaking => "Shaking…";
  @override
  String get shake => "Shake the cylinder";
  @override
  String get youDrew => "You drew";
  @override
  String get shakeAgain => "Shake again";
  @override
  String get jiaoSacredName => "Sacred cast";
  @override
  String get jiaoLaughingName => "Laughing cast";
  @override
  String get jiaoNegativeName => "Negative cast";
  @override
  String get jiaoSacredMsg => "The deity approves — this lot is meant for you.";
  @override
  String get jiaoLaughingMsg => "The deity smiles without answering — refocus and cast again.";
  @override
  String get jiaoNegativeMsg => "The deity declines — this may not be your lot; draw anew.";
  @override
  String get drawAnew => "Draw anew";
  @override
  String get jiaoAskHint => "Focus on your question, then cast to ask if the deity approves this lot";
  @override
  String get jiaoCasting => "Casting…";
  @override
  String get jiaoRead => "Read the lot";
  @override
  String get cast => "Cast";
  @override
  String get castAgain => "Cast again";
  @override
  String get readAnyway => "Read anyway";
  @override
  String get threeSacred => "Three sacred casts — your sincerity moves heaven!";
  @override
  String get shareThisLot => "Share this lot";
  @override
  String get favorite => "Favorite";
  @override
  String get externalAiNote => "※ No local database for this set; the reading below is AI-inferred from the poem.";
  @override
  String get sectionPlain => "In plain words";
  @override
  String get sectionAllusion => "Allusion";
  @override
  String get sectionShengyi => "Oracle notes";
  @override
  String get sectionJieyue => "Interpretation";
  @override
  String get sectionAspects => "Six aspects";
  @override
  String get askReadingTitle => "Ask for a reading";
  @override
  String get askReadingSubtitle => "Share what is on your mind for a reading tailored to you";
  @override
  String get questionHint => "e.g. I am thinking of changing jobs — is now a good time?";
  @override
  String get interpreting => "The interpreter is reflecting…";
  @override
  String get askAi => "Ask AI to interpret";
  @override
  String get interpreterVoice => "From the interpreter";
  @override
  String get readingDisclaimer => "Readings are for reflection only; consult a professional for major decisions";
  @override
  String get aspectCareer => "Career";
  @override
  String get aspectLove => "Love";
  @override
  String get aspectWealth => "Wealth";
  @override
  String get aspectHealth => "Health";
  @override
  String get aspectStudy => "Study";
  @override
  String get aspectTravel => "Travel";
  @override
  String get historyTitle => "History";
  @override
  String get tabAll => "All";
  @override
  String get emptyFavorites => "No favorites yet\nTap ♥ on a lot to save it";
  @override
  String get emptyHistory => "No lots yet\nDraw one to begin";
  @override
  String get sourcePhoto => "Photo";
  @override
  String get sourceDraw => "Draw";
  @override
  String get sourceManual => "Manual";
  @override
  String get appearance => "Appearance";
  @override
  String get themeSystem => "System default";
  @override
  String get themeLight => "Day shrine (light)";
  @override
  String get themeDark => "Night shrine (dark)";
  @override
  String get language => "Language";
  @override
  String get aiService => "AI service";
  @override
  String get apiKeySet => "Set ✓";
  @override
  String get apiKeyHint => "Paste your API key";
  @override
  String get apiKeyHelper => "The key is stored only on your device";
  @override
  String get save => "Save";
  @override
  String get apiKeySaved => "API key saved";
  @override
  String get visionModel => "Vision model";
  @override
  String get textModel => "Interpretation model";
  @override
  String get about => "About";
  @override
  String get aboutBody => "Divination lots carry a long heritage. MindLot presents these traditional poems with respect and adds AI-assisted readings. Interpretations are for reflection and comfort only — they are not medical, legal, or financial advice; consult a professional for important decisions.\n\nMay your sincerity be met with peace and joy.";
  @override
  String get shareImage => "Share image";
  @override
  String get preparing => "Preparing…";
  @override
  String get shareFailed => "Sharing failed — try again";
  @override
  String photoLoadError(Object e) => "Could not load photo: $e";
  @override
  String cameraOpenError(Object e) => "Could not open camera: $e";
  @override
  String confidence(int p) => "Confidence $p%";
  @override
  String cameraStartFailedCode(String code) => "Camera failed to start ($code).";
  @override
  String allusionTitle(String title) => "Allusion: $title";
  @override
  String noteLine(String note) => "※ $note";
  @override
  String numberRangeError(int max) => "Enter a number between 1 and $max";
  @override
  String numberRangeHint(int max) => "1 – $max";
  @override
  String lotNotYetAdded(int number) => "Lot $number is not in the database yet — coming in a future update.";
  @override
  String setLoadError(Object e) => "Failed to load lot data: $e";
  @override
  String loadError(Object e) => "Failed to load: $e";
  @override
  String questionPrefix(String q) => "Q: $q";
  @override
  String jiaoAsk(String set, String label) => "Drew “$set・$label”";
}

class AppLocalizationsZhHant extends AppLocalizations {
  @override
  String get appName => "心籤通";
  @override
  String get homeMotto => "掌中靈籤，心誠則靈";
  @override
  String get settings => "設定";
  @override
  String get recentRecords => "近期籤記";
  @override
  String get viewAll => "全部 ›";
  @override
  String get emptyRecent => "尚無紀錄，求一支籤開始吧";
  @override
  String get appFooter => "籤詩乃心之明鏡，指引而非定命";
  @override
  String get ritePhotoTitle => "拍照辨籤";
  @override
  String get ritePhotoSubtitle => "拍下廟中求得的籤枝或籤詩\nAI 為您辨識並解籤";
  @override
  String get riteDrawTitle => "線上求籤";
  @override
  String get riteDrawSubtitle => "默念心中所求，搖籤筒\n誠心抽出一支靈籤";
  @override
  String get photoHint => "請拍攝籤枝或籤詩紙\n盡量正對、光線充足、避免反光";
  @override
  String get takePhoto => "拍照";
  @override
  String get gallery => "相簿";
  @override
  String get analyzing => "AI 辨識中⋯";
  @override
  String get startRecognition => "開始辨識";
  @override
  String get manualInput => "手動輸入籤號";
  @override
  String get skipToManual => "略過拍照，直接手動輸入 ›";
  @override
  String get recognitionResult => "辨識結果";
  @override
  String get lowConfidenceNote => "※ 辨識信心較低，請核對籤號是否正確";
  @override
  String get correct => "不對，修正";
  @override
  String get castConsult => "擲筊請示";
  @override
  String get skipCastRead => "不擲筊，直接解籤";
  @override
  String get photoNotRecognized => "照片中未能辨識出籤枝或籤詩，請重拍或改用手動輸入。";
  @override
  String get poemMatchedNoSet => "辨識到籤詩但無法對應籤庫，請確認或手動輸入。";
  @override
  String get matchedByPoem => "已由籤詩內容比對出此籤";
  @override
  String get unknownSet => "未知籤種";
  @override
  String get externalPhotoNote => "此籤種尚無本地籤庫，將以照片擷取的籤詩進行 AI 解籤";
  @override
  String get fixNumber => "修正籤號";
  @override
  String get back => "返回";
  @override
  String get torch => "補光";
  @override
  String get retry => "重試";
  @override
  String get noCameraFound => "找不到可用的相機。";
  @override
  String get cameraAccessDenied => "無法使用相機——請在系統設定中允許本 App 存取相機。";
  @override
  String get cameraStartFailed => "相機啟動失敗，請改用相簿或手動輸入。";
  @override
  String get captureFailed => "拍攝失敗，請再試一次";
  @override
  String get frameAlign => "將籤枝或籤詩對準框內";
  @override
  String get frameHint => "正對、光線充足、避免反光";
  @override
  String get selectSetFirst => "請先選擇籤種";
  @override
  String get lotNumberLabel => "籤號";
  @override
  String get viewThisLot => "查閱此籤";
  @override
  String get querying => "查詢中⋯";
  @override
  String get drawInstruction => "默念您想請示的事情\n心誠則靈";
  @override
  String get shaking => "搖籤中⋯";
  @override
  String get shake => "誠心搖籤";
  @override
  String get youDrew => "您求得";
  @override
  String get shakeAgain => "再搖一次";
  @override
  String get jiaoSacredName => "聖筊";
  @override
  String get jiaoLaughingName => "笑筊";
  @override
  String get jiaoNegativeName => "陰筊";
  @override
  String get jiaoSacredMsg => "神明應允，此籤正是為您而降。";
  @override
  String get jiaoLaughingMsg => "神明含笑未答，心念一想，再擲一次。";
  @override
  String get jiaoNegativeMsg => "神明搖首，此籤或非所問，可重新求籤。";
  @override
  String get drawAnew => "重新求籤";
  @override
  String get jiaoAskHint => "誠心默念所問，擲筊請示神明是否應允此籤";
  @override
  String get jiaoCasting => "擲筊中⋯";
  @override
  String get jiaoRead => "恭請解籤";
  @override
  String get cast => "擲筊";
  @override
  String get castAgain => "再擲一次";
  @override
  String get readAnyway => "仍要解籤";
  @override
  String get threeSacred => "連得三聖筊，心誠格天！";
  @override
  String get shareThisLot => "分享此籤";
  @override
  String get favorite => "收藏";
  @override
  String get externalAiNote => "※ 此籤種尚未收錄本地籤庫，以下解讀由 AI 依籤詩原文推敲。";
  @override
  String get sectionPlain => "白話淺釋";
  @override
  String get sectionAllusion => "典故";
  @override
  String get sectionShengyi => "聖意";
  @override
  String get sectionJieyue => "解曰";
  @override
  String get sectionAspects => "六事指引";
  @override
  String get askReadingTitle => "請示解籤";
  @override
  String get askReadingSubtitle => "告訴解籤師您的心事，獲得專屬於您的籤解";
  @override
  String get questionHint => "例如：我正在考慮換工作，這個時機合適嗎？";
  @override
  String get interpreting => "解籤師沉思中⋯";
  @override
  String get askAi => "請 AI 解籤";
  @override
  String get interpreterVoice => "解籤師的話";
  @override
  String get readingDisclaimer => "籤解僅供參考，重大決定請諮詢專業意見";
  @override
  String get aspectCareer => "事業";
  @override
  String get aspectLove => "感情";
  @override
  String get aspectWealth => "財運";
  @override
  String get aspectHealth => "健康";
  @override
  String get aspectStudy => "學業";
  @override
  String get aspectTravel => "出行";
  @override
  String get historyTitle => "籤記";
  @override
  String get tabAll => "全部";
  @override
  String get emptyFavorites => "尚無收藏的籤\n在籤詩頁點擊 ♥ 即可收藏";
  @override
  String get emptyHistory => "尚無籤記\n求一支籤開始吧";
  @override
  String get sourcePhoto => "拍照";
  @override
  String get sourceDraw => "線上";
  @override
  String get sourceManual => "手動";
  @override
  String get appearance => "外觀";
  @override
  String get themeSystem => "跟隨系統";
  @override
  String get themeLight => "日殿（淺色）";
  @override
  String get themeDark => "夜殿（深色）";
  @override
  String get language => "語言";
  @override
  String get aiService => "AI 服務";
  @override
  String get apiKeySet => "已設定 ✓";
  @override
  String get apiKeyHint => "請貼上您的 API 金鑰";
  @override
  String get apiKeyHelper => "金鑰僅儲存在您的裝置上";
  @override
  String get save => "儲存";
  @override
  String get apiKeySaved => "已儲存 API 金鑰";
  @override
  String get visionModel => "影像辨識模型";
  @override
  String get textModel => "解籤模型";
  @override
  String get about => "關於";
  @override
  String get aboutBody => "籤詩文化源遠流長，本應用以敬重之心呈現傳統籤詩，並以 AI 輔助解讀。籤解內容僅供參考與心靈陪伴，不構成醫療、法律或財務建議；重大決定請諮詢專業人士。\n\n願您心誠所至，平安喜樂。";
  @override
  String get shareImage => "分享圖片";
  @override
  String get preparing => "準備中⋯";
  @override
  String get shareFailed => "分享失敗，請再試一次";
  @override
  String photoLoadError(Object e) => "無法取得照片：$e";
  @override
  String cameraOpenError(Object e) => "無法開啟相機：$e";
  @override
  String confidence(int p) => "信心 $p%";
  @override
  String cameraStartFailedCode(String code) => "相機啟動失敗（$code）。";
  @override
  String allusionTitle(String title) => "籤題：$title";
  @override
  String noteLine(String note) => "※ $note";
  @override
  String numberRangeError(int max) => "請輸入 1–$max 之間的籤號";
  @override
  String numberRangeHint(int max) => "1 – $max";
  @override
  String lotNotYetAdded(int number) => "第 $number 籤的資料尚未收錄，敬請期待後續更新。";
  @override
  String setLoadError(Object e) => "籤庫載入失敗：$e";
  @override
  String loadError(Object e) => "載入失敗：$e";
  @override
  String questionPrefix(String q) => "問：$q";
  @override
  String jiaoAsk(String set, String label) => "求得「$set・$label」";
}

class AppLocalizationsZhHans extends AppLocalizations {
  @override
  String get appName => "心签通";
  @override
  String get homeMotto => "掌中灵签，心诚则灵";
  @override
  String get settings => "设置";
  @override
  String get recentRecords => "近期签记";
  @override
  String get viewAll => "全部 ›";
  @override
  String get emptyRecent => "尚无纪录，求一支签开始吧";
  @override
  String get appFooter => "签诗乃心之明镜，指引而非定命";
  @override
  String get ritePhotoTitle => "拍照辨签";
  @override
  String get ritePhotoSubtitle => "拍下庙中求得的签枝或签诗\nAI 为您辨识并解签";
  @override
  String get riteDrawTitle => "在线求签";
  @override
  String get riteDrawSubtitle => "默念心中所求，摇签筒\n诚心抽出一支灵签";
  @override
  String get photoHint => "请拍摄签枝或签诗纸\n尽量正对、光线充足、避免反光";
  @override
  String get takePhoto => "拍照";
  @override
  String get gallery => "图库";
  @override
  String get analyzing => "AI 辨识中⋯";
  @override
  String get startRecognition => "开始辨识";
  @override
  String get manualInput => "手动输入签号";
  @override
  String get skipToManual => "略过拍照，直接手动输入 ›";
  @override
  String get recognitionResult => "辨识结果";
  @override
  String get lowConfidenceNote => "※ 辨识信心较低，请核对签号是否正确";
  @override
  String get correct => "不对，修正";
  @override
  String get castConsult => "掷筊请示";
  @override
  String get skipCastRead => "不掷筊，直接解签";
  @override
  String get photoNotRecognized => "照片中未能辨识出签枝或签诗，请重拍或改用手动输入。";
  @override
  String get poemMatchedNoSet => "辨识到签诗但无法对应签库，请确认或手动输入。";
  @override
  String get matchedByPoem => "已由签诗内容比对出此签";
  @override
  String get unknownSet => "未知签种";
  @override
  String get externalPhotoNote => "此签种尚无本地签库，将以照片截取的签诗进行 AI 解签";
  @override
  String get fixNumber => "修正签号";
  @override
  String get back => "返回";
  @override
  String get torch => "补光";
  @override
  String get retry => "重试";
  @override
  String get noCameraFound => "找不到可用的相机。";
  @override
  String get cameraAccessDenied => "无法使用相机——请在系统设置中允许本 App 访问相机。";
  @override
  String get cameraStartFailed => "相机启动失败，请改用图库或手动输入。";
  @override
  String get captureFailed => "拍摄失败，请再试一次";
  @override
  String get frameAlign => "将签枝或签诗对准框内";
  @override
  String get frameHint => "正对、光线充足、避免反光";
  @override
  String get selectSetFirst => "请先选择签种";
  @override
  String get lotNumberLabel => "签号";
  @override
  String get viewThisLot => "查阅此签";
  @override
  String get querying => "查找中⋯";
  @override
  String get drawInstruction => "默念您想请示的事情\n心诚则灵";
  @override
  String get shaking => "摇签中⋯";
  @override
  String get shake => "诚心摇签";
  @override
  String get youDrew => "您求得";
  @override
  String get shakeAgain => "再摇一次";
  @override
  String get jiaoSacredName => "圣筊";
  @override
  String get jiaoLaughingName => "笑筊";
  @override
  String get jiaoNegativeName => "阴筊";
  @override
  String get jiaoSacredMsg => "神明应允，此签正是为您而降。";
  @override
  String get jiaoLaughingMsg => "神明含笑未答，心念一想，再掷一次。";
  @override
  String get jiaoNegativeMsg => "神明摇首，此签或非所问，可重新求签。";
  @override
  String get drawAnew => "重新求签";
  @override
  String get jiaoAskHint => "诚心默念所问，掷筊请示神明是否应允此签";
  @override
  String get jiaoCasting => "掷筊中⋯";
  @override
  String get jiaoRead => "恭请解签";
  @override
  String get cast => "掷筊";
  @override
  String get castAgain => "再掷一次";
  @override
  String get readAnyway => "仍要解签";
  @override
  String get threeSacred => "连得三圣筊，心诚格天！";
  @override
  String get shareThisLot => "分享此签";
  @override
  String get favorite => "收藏";
  @override
  String get externalAiNote => "※ 此签种尚未收录本地签库，以下解读由 AI 依签诗原文推敲。";
  @override
  String get sectionPlain => "白话浅释";
  @override
  String get sectionAllusion => "典故";
  @override
  String get sectionShengyi => "圣意";
  @override
  String get sectionJieyue => "解曰";
  @override
  String get sectionAspects => "六事指引";
  @override
  String get askReadingTitle => "请示解签";
  @override
  String get askReadingSubtitle => "告诉解签师您的心事，获得专属于您的签解";
  @override
  String get questionHint => "例如：我正在考虑换工作，这个时机合适吗？";
  @override
  String get interpreting => "解签师沉思中⋯";
  @override
  String get askAi => "请 AI 解签";
  @override
  String get interpreterVoice => "解签师的话";
  @override
  String get readingDisclaimer => "签解仅供参考，重大决定请咨询专业意见";
  @override
  String get aspectCareer => "事业";
  @override
  String get aspectLove => "感情";
  @override
  String get aspectWealth => "财运";
  @override
  String get aspectHealth => "健康";
  @override
  String get aspectStudy => "学业";
  @override
  String get aspectTravel => "出行";
  @override
  String get historyTitle => "签记";
  @override
  String get tabAll => "全部";
  @override
  String get emptyFavorites => "尚无收藏的签\n在签诗页点击 ♥ 即可收藏";
  @override
  String get emptyHistory => "尚无签记\n求一支签开始吧";
  @override
  String get sourcePhoto => "拍照";
  @override
  String get sourceDraw => "在线";
  @override
  String get sourceManual => "手动";
  @override
  String get appearance => "外观";
  @override
  String get themeSystem => "跟随系统";
  @override
  String get themeLight => "日殿（浅色）";
  @override
  String get themeDark => "夜殿（深色）";
  @override
  String get language => "语言";
  @override
  String get aiService => "AI 服务";
  @override
  String get apiKeySet => "已设置 ✓";
  @override
  String get apiKeyHint => "请粘贴您的 API 密钥";
  @override
  String get apiKeyHelper => "密钥仅保存在您的设备上";
  @override
  String get save => "保存";
  @override
  String get apiKeySaved => "已保存 API 密钥";
  @override
  String get visionModel => "影像辨识模型";
  @override
  String get textModel => "解签模型";
  @override
  String get about => "关于";
  @override
  String get aboutBody => "签诗文化源远流长，本应用以敬重之心呈现传统签诗，并以 AI 辅助解读。签解内容仅供参考与心灵陪伴，不构成医疗、法律或财务建议；重大决定请咨询专业人士。\n\n愿您心诚所至，平安喜乐。";
  @override
  String get shareImage => "分享图片";
  @override
  String get preparing => "准备中⋯";
  @override
  String get shareFailed => "分享失败，请再试一次";
  @override
  String photoLoadError(Object e) => "无法取得照片：$e";
  @override
  String cameraOpenError(Object e) => "无法打开相机：$e";
  @override
  String confidence(int p) => "信心 $p%";
  @override
  String cameraStartFailedCode(String code) => "相机启动失败（$code）。";
  @override
  String allusionTitle(String title) => "签题：$title";
  @override
  String noteLine(String note) => "※ $note";
  @override
  String numberRangeError(int max) => "请输入 1–$max 之间的签号";
  @override
  String numberRangeHint(int max) => "1 – $max";
  @override
  String lotNotYetAdded(int number) => "第 $number 签的数据尚未收录，敬请期待后续更新。";
  @override
  String setLoadError(Object e) => "签库加载失败：$e";
  @override
  String loadError(Object e) => "加载失败：$e";
  @override
  String questionPrefix(String q) => "问：$q";
  @override
  String jiaoAsk(String set, String label) => "求得「$set・$label」";
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  if (locale.languageCode == 'zh') {
    if (locale.scriptCode == 'Hans' ||
        locale.countryCode == 'CN' ||
        locale.countryCode == 'SG' ||
        locale.countryCode == 'MY') {
      return AppLocalizationsZhHans();
    }
    return AppLocalizationsZhHant();
  }
  return AppLocalizationsEn();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == 'en' || locale.languageCode == 'zh';

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
