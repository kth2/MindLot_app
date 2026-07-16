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
| 🔁 **Graceful fallbacks**: poem fuzzy-matching when the number is unreadable → AI interpretation from extracted poem when the set isn't in the local DB → manual input | ✅ |
| 🎋 **Traditional drawing**: animated shaking cylinder with sound | ✅ |
| 🤖 **Personalized AI interpretation** for the user's own question (career/love/wealth/health/study/travel) | ✅ |
| 🗂️ History & favorites (persisted locally) | ✅ |
| 🌙 Dark mode（夜殿）/ light mode（日殿）, temple-inspired UI, vertical classical poem layout | ✅ |
| 🈯 Multi-set data model: 觀音靈籤 (bundled, lots 1–10 sample) · 媽祖靈籤 · 六十甲子籤 · 黃大仙靈籤 (recognized from photos; local DBs planned) | 🚧 |

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

**iOS — `ios/Runner/Info.plist`**
```xml
<key>NSCameraUsageDescription</key>
<string>拍攝籤枝或籤詩以進行辨識</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>從相簿選擇籤詩照片以進行辨識</string>
```

**Android** — `image_picker` needs no manifest changes on API 33+; for older
devices the plugin handles the runtime permission flow itself.

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
│   └── audio/                    # shake sound
├── providers/                    # Riverpod wiring (settings, history, DI)
└── features/                     # one folder per screen
    ├── home/  photo/  draw/  lot/  history/  settings/
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
  "level": "上上",              // 籤等
  "title": "開天闢地",           // 籤題（典故名）
  "poem": ["天開地闢結良緣", "..."],
  "poemTranslation": "白話淺釋…",
  "allusion": "典故說明…",
  "meaning": "解曰…",
  "aspects": { "career": "…", "love": "…", "wealth": "…",
               "health": "…", "study": "…", "travel": "…" },
  "keywords": ["開創", "良緣"]
}
```

Adding a new lot system = one JSON file + one registry entry. No code changes.

> ⚠️ **Data accuracy**: the bundled poems follow the widely-circulated
> 觀音一百籤 version; individual temples use slightly different texts and
> fortune-level assignments. Verify against your target temple's official
> text before production release. `guanyin_100.json` currently contains lots
> 1–10 as a reviewed sample; 11–100 follow the identical schema.

## 🙏 Design Principles

- **Respect for tradition**: original poems, allusions, and 解曰 are presented
  faithfully; the AI interpreter is prompted to ground itself in them.
- **Positive & encouraging**: even 下下 lots are read as reminders and turning
  points — never fatalistic threats.
- **Humble boundaries**: the app reminds users that readings are guidance, and
  to consult professionals for medical/legal/financial decisions.

## 🗺️ Roadmap

- [ ] Complete 觀音靈籤 11–100; add 媽祖六十甲子籤, 黃大仙靈籤 databases
- [ ] In-app live viewfinder with the `camera` package (guided framing overlay)
- [ ] 擲筊 confirmation flow after drawing
- [ ] Share a lot card as an image
- [ ] i18n (zh-TW / zh-CN / en)

## 📚 Acknowledgements

Inspired by (no code copied): [westleft/fortuneStick](https://github.com/westleft/fortuneStick),
[wickes1/wong-tai-sin](https://github.com/wickes1/wong-tai-sin),
[huangdaxian-lingqian.skill](https://github.com/leslietong2046-ship-it/huangdaxian-lingqian.skill),
[aws_kiro_fortune_telling_game](https://github.com/tekvinci/aws_kiro_fortune_telling_game).
