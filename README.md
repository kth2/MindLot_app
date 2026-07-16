# 心籤通 MindLot 🏮

A cross-platform (iOS / Android) divination-lot companion built with **Flutter**.
Photograph a real lot drawn at a temple, let Vision AI identify it, or shake a
virtual cylinder — then receive a warm, personalized AI interpretation.

> 籤詩乃心之明鏡，指引而非定命。
> Lot poems are a mirror for the heart — guidance, not fate.

## ✨ Features

| Feature | Status |
|---|---|
| 📷 **Photo recognition** of physical lots (籤枝/籤詩紙) via Gemini Vision — identifies lot type, number (incl. Chinese numerals & 干支), and extracts the poem | ✅ |
| 🎯 **In-app live viewfinder** with a framing overlay & torch (`camera` package) for guided capture, gallery picker as an alternative | ✅ |
| 🔁 **Graceful fallbacks**: poem fuzzy-matching when the number is unreadable → AI interpretation from extracted poem when the set isn't in the local DB → manual input | ✅ |
| 🎋 **Traditional drawing**: animated shaking cylinder with sound | ✅ |
| 🥮 **擲筊 confirmation**: throw the moon blocks (聖筊/笑筊/陰筊) to ask the deity's approval before reading a lot — on both the draw and photo flows | ✅ |
| 🤖 **Personalized AI interpretation** for the user's own question (career/love/wealth/health/study/travel) | ✅ |
| 🗂️ History & favorites (persisted locally) | ✅ |
| 🌙 Dark mode（夜殿）/ light mode（日殿）, temple-inspired UI, vertical classical poem layout | ✅ |
| 🈯 Multi-set data model: 觀音靈籤 (**100 lots**) · 媽祖六十甲子籤 (**60 lots**, with 五行方位 & 聖意) · 六十甲子籤 (**60 lots**, shares the Mazu poem system) · 黃大仙靈籤 (**100 lots**, with 典故 & 解籤) | ✅ |

## 🚀 Getting Started

The repo intentionally contains only the Dart/Flutter source, assets and config —
generate the platform folders locally:

```bash
git clone <this repo> && cd MindLot_app

# 1. Generate android/ ios/ (and optionally other platforms)
flutter create . --org com.mindlot --project-name mindlot --platforms android,ios

# 2. Install dependencies
flutter pub get

# 3. Run — pass your Gemini API key (or set it later in-app under 設定)
flutter run --dart-define=GEMINI_API_KEY=your_key_here
```

Get a free Gemini API key at <https://aistudio.google.com/apikey>.
The key can also be entered at runtime in **Settings → AI 服務** (stored only on-device).

### Required permissions

After `flutter create .`, add:

**iOS — `ios/Runner/Info.plist`** (the in-app viewfinder and gallery picker
share these keys)
```xml
<key>NSCameraUsageDescription</key>
<string>拍攝籤枝或籤詩以進行辨識</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>從相簿選擇籤詩照片以進行辨識</string>
```

**Android** — the `camera` plugin requires `minSdkVersion 21`; set it in
`android/app/build.gradle` (`defaultConfig { minSdkVersion 21 }`) if the
generated default is lower. The CAMERA permission is merged in by the plugin;
`image_picker` needs no manifest changes on API 33+.

### Tests

```bash
flutter test
```

## 🏗️ Architecture

```
lib/
├── main.dart / app.dart          # entry, ProviderScope, MaterialApp.router
├── core/
│   ├── theme/                    # temple palette + light/dark ThemeData
│   └── router/                   # go_router routes (+ LotDetailArgs)
├── data/
│   ├── models/                   # Lot, LotSet, VisionResult, DivinationRecord
│   └── repositories/             # LotRepository (JSON assets), HistoryRepository (prefs)
├── services/
│   ├── ai/
│   │   ├── vision_service.dart          # abstract — provider-agnostic
│   │   ├── interpretation_service.dart  # abstract — provider-agnostic
│   │   ├── gemini_client.dart           # tiny Gemini REST client (one file!)
│   │   ├── gemini_vision_service.dart
│   │   ├── gemini_interpretation_service.dart
│   │   └── prompts.dart                 # all prompt templates, tunable in one place
│   └── audio/                    # shake + 擲筊 sounds
├── providers/                    # Riverpod wiring (settings, history, DI)
└── features/                     # one folder per screen
    ├── home/
    ├── photo/   # recognition screen + in-app CameraCaptureScreen + framing overlay
    ├── draw/    # cylinder + 擲筊 (moon-block) ritual
    ├── lot/  history/  settings/
```

**State management** is classic Riverpod (`Notifier`/`AsyncNotifier`, no codegen).

**Switching AI providers**: implement `VisionService` + `InterpretationService`
and change two bindings in `lib/providers/providers.dart`. The Gemini model id
itself (1.5 Flash / 1.5 Pro / 2.0 Flash) is switchable at runtime in Settings.

### Photo-recognition pipeline

```
photo ─► Gemini Vision (strict-JSON prompt, registry injected as vocabulary)
      ─► resolve, in order of trust:
         1. setId + lot number  ──► local DB hit
         2. setId + 干支         ──► local DB hit
         3. extracted poem       ──► fuzzy char-overlap match against all local lots
         4. poem only            ──► ephemeral "external" lot, AI interprets the poem text
         5. nothing              ──► manual input sheet (set + number)
      ─► user confirms/corrects  ──► interpretation screen
```

The model is explicitly instructed **never to reconstruct poems from memory** —
only text actually visible in the photo is returned, so a blurry photo degrades
to fallbacks instead of hallucinations.

## 📄 Data Format

All lot data ships as JSON under `assets/data/`:

- `lot_sets.json` — registry of lot systems (id, deity, total count, numbering
  style `numeric`/`sexagenary`, aliases used as the Vision AI's classification
  vocabulary, and the per-set data file).
- `<set_id>.json` — the lots themselves:

```jsonc
{
  "id": "guanyin_100_001",
  "number": 1,
  "label": "第一籤",
  "sexagenary": null,          // "丁亥" for 60-jiazi systems
  "level": "上籤",              // 籤等（上籤/中籤/下籤）
  "title": "鍾離成道",           // 籤題（典故名）
  "poem": ["開天闢地作良緣", "..."],
  "poemTranslation": "白話淺釋…",
  "allusion": "典故說明…",
  "meaning": "解曰…",           // for 六十甲子系統: the per-topic 聖意 items
  "wuxing": "",                // 六十甲子系統 only, e.g. "屬金，利在秋天，宜其西方"
  "aspects": { "career": "…", "love": "…", "wealth": "…",
               "health": "…", "study": "…", "travel": "…" },
  "keywords": ["開創", "良緣"]
}
```

Adding a new lot system = one JSON file + one registry entry. No code changes.
`level` may be empty (媽祖六十甲子籤 carries no single fortune grade — its 吉凶
lives in the poem and 聖意), and the optional `wuxing` field is rendered only
when present. Two registry entries may point at the **same** `dataFile`
(六十甲子籤 reuses 媽祖's poems); `loadLots` stamps each lot with the requested
`setId`, so the sets stay distinct in history and the UI while sharing one
source file.

> ⚠️ **Data accuracy**: `guanyin_100.json` now contains the **complete 100
> lots**. Poems, fortune levels (上籤/中籤/下籤) and allusion titles come from a
> publicly available, human-verified 觀音靈籤 dataset (converted to Traditional
> Chinese with OpenCC); the 白話 paraphrase, allusion notes, six-aspect
> guidance and keywords are authored for this app; `meaning` keeps the
> traditional 解曰. Individual temples use slightly different wording — verify
> against your target temple's official text before production release.
>
> `mazu_60.json` contains the **complete 60 lots**. Poems, 五行方位, 古人典故
> and the per-topic 聖意 come from the public
> [DestinyLab/lottery-poetry-sixty-jiazi](https://github.com/DestinyLab/lottery-poetry-sixty-jiazi)
> dataset; the 白話 paraphrase, allusion notes, six-aspect guidance and
> keywords are authored for this app. The sexagenary order follows the
> traditional stem-grouped sequence (甲子·甲寅·甲辰·甲午·甲申·甲戌, 乙丑·乙卯…
> — yang stems with yang branches), **not** the continuous 干支 cycle. Same
> verify-before-release caveat applies.
>
> `wongtaisin_100.json` contains the **complete 100 lots** (嗇色園黃大仙祠款).
> Poems, 吉凶 grades, 籤題, 典故, 解籤 and the per-category guidance come from
> the public [wickes1/wong-tai-sin](https://github.com/wickes1/wong-tai-sin)
> dataset; only the 白話 paraphrase and keywords are authored for this app.
> Lot 79's source text dropped its final character — restored to the common
> reading (…土一坵). Same verify-before-release caveat applies.

## 🙏 Design Principles

- **Respect for tradition**: original poems, allusions, and 解曰 are presented
  faithfully; the AI interpreter is prompted to ground itself in them.
- **Positive & encouraging**: even 下籤 lots are read as reminders and turning
  points — never fatalistic threats.
- **Humble boundaries**: the app reminds users that readings are guidance, and
  to consult professionals for medical/legal/financial decisions.

## 🗺️ Roadmap

- [x] Complete 觀音靈籤 all 100 lots
- [x] Complete 媽祖六十甲子籤 all 60 lots
- [x] Wire up 六十甲子籤 (王爺/保生大帝廟) — shares the Mazu poem system
- [x] Complete 黃大仙靈籤 all 100 lots — **all four registered sets now have data**
- [x] 擲筊 confirmation flow (moon blocks: 聖筊/笑筊/陰筊) on both draw & photo flows
- [x] In-app live viewfinder with the `camera` package (framing overlay + torch)
- [ ] Share a lot card as an image
- [ ] i18n (zh-TW / zh-CN / en)

## 📚 Acknowledgements

Inspired by (no code copied): [westleft/fortuneStick](https://github.com/westleft/fortuneStick),
[wickes1/wong-tai-sin](https://github.com/wickes1/wong-tai-sin),
[huangdaxian-lingqian.skill](https://github.com/leslietong2046-ship-it/huangdaxian-lingqian.skill),
[aws_kiro_fortune_telling_game](https://github.com/tekvinci/aws_kiro_fortune_telling_game).

觀音靈籤 poems, fortune levels and allusion titles adapted from the
publicly-shared, human-verified dataset
[yanxinyu777-beep/guanyin-lingqian-100](https://github.com/yanxinyu777-beep/guanyin-lingqian-100)
(converted to Traditional Chinese). 媽祖六十甲子籤 poems, 五行方位, 古人典故 and
per-topic 聖意 adapted from
[DestinyLab/lottery-poetry-sixty-jiazi](https://github.com/DestinyLab/lottery-poetry-sixty-jiazi)
(MIT). 黃大仙靈籤 poems, 吉凶 grades, 籤題, 典故, 解籤 and per-category guidance
adapted from [wickes1/wong-tai-sin](https://github.com/wickes1/wong-tai-sin).
The 白話 paraphrase and keywords across all datasets — plus the allusion notes
and six-aspect guidance for the Guanyin and Mazu sets — are original to this
project.
