# Dynamic UI Playground
<img width="190" height="380" alt="Simulator Screenshot - iPhone 16 Pro Max - 2025-08-13 at 20 27 18" src="https://github.com/user-attachments/assets/ea765735-5dea-4927-bf34-f486a0f3a9f3" />
<img width="190" height="380" alt="Simulator Screenshot - iPhone 16 Pro Max - 2025-08-13 at 20 36 47" src="https://github.com/user-attachments/assets/9ca7a58c-34cd-4323-9e3f-068d2e6af81f" />
<img width="190" height="380" alt="Simulator Screenshot - iPhone 16 Pro Max - 2025-08-13 at 20 32 14" src="https://github.com/user-attachments/assets/e4c154ce-eefa-4e9a-960c-3752bae8f68f" />
<img width="190" height="380" alt="Simulator Screenshot - iPhone 16 Pro Max - 2025-08-13 at 20 32 36" src="https://github.com/user-attachments/assets/46179d54-53b8-4eb3-9cb3-e9c7bdc6961d" />
<img width="190" height="380" alt="Simulator Screenshot - iPhone 16 Pro Max - 2025-08-13 at 20 38 26" src="https://github.com/user-attachments/assets/97d538c0-80f5-4308-8a21-0e46aaced572" />


A tiny, expressive mobile playground where natural language turns into live UI.
Type a prompt (or pick a suggestion) and watch the layout morph in real time. Long‑press the title for a surprise.

This repo is the result of an LLM‑assisted build session. The goal: demonstrate how we use AI to code faster, reason better, and ship delightful interactions.

## Live Demo

https://joaopauloubaf.github.io/dynamic-ui-playground-demo/

## Highlights

- Dynamic UI from JSON
  - A small design system renders Flutter widgets from a concise JSON schema.
  - Clear, visible changes: text, inputs, images, buttons, rows/columns, padding, scroll, etc.
- Mocked prompts (required) + optional LLM (bonus)
  - Five "Create" prompts return curated JSON instantly.
  - Update prompts (mocked patterns) apply precise edits to the current JSON.
  - Optional: Firebase Generative AI can generate/update JSON from free‑form text.
- Testable by design
  - Widget tests for the JSON builder.
  - Integration test that runs the “Create” flow end‑to‑end.

  Bonus:
- Theme Easter Egg
  - Seed‑based Material 3 theme (ColorScheme.fromSeed).
  - Long‑press the “Dynamic UI” title to apply a random AI‑generated theme (fonts + seed color) with an opaque loading overlay.
  - Default seed color: Amber.

## Quick Start

### Deploy (GitHub Pages)

- One command to build and publish the web demo to the separate repo:

```bash
./scripts/deploy_pages.sh
```

- To publish to a different repo/name/branch, override via env vars:

```bash
REPO_URL=https://github.com/<user>/<repo>.git \
REPO_NAME=<repo> \
BRANCH=main \
./scripts/deploy_pages.sh
```

Prerequisites
- Flutter 3.22+ (stable recommended)
- Dart 3.x
- Xcode (for iOS) / Android Studio (for Android)
- A device or emulator/simulator or run it on web browser (The project was developed using a iPhone 16 Pro Max emulator, it will present the best experience)

Clone

```bash
git clone https://github.com/your-org/dynamic_ui_playground.git
cd dynamic_ui_playground
```

Install deps

```bash
flutter pub get
```

Run (pick one)

```bash
# iOS simulator (recommended)
flutter run -d ios

# Android emulator
flutter run -d android

# Web (Chrome)
flutter run -d chrome

# Any connected device
flutter run
```

That’s it. You should see a simple screen titled “Dynamic UI”, an input FAB, and suggested prompts.

## How to use

- Tap the floating action button
  - Pick a “Create” suggestion to instantly load a demo UI
    - Login screen
    - Profile header
    - Product grid
    - News list
    - Settings page
  - Or type an “Update” command (see examples below)
- Long‑press the AppBar title (“Dynamic UI”)
  - Applies a random AI‑generated theme (seed color + fonts)
  - An opaque loader appears briefly while the magic happens

Update prompt examples (mocked patterns)
- “Change the background color to #3d2d01”
- “Round the input borders by 20”
- “Remove the last item”
- “Add a text widget after image widget”
- “Change the image fit to cover”
- “Change the image size to 300x180”
- “Change the fontfamily to Bebas Neue”

## Project structure

- lib/
  - features/
    - dynamic_ui/
      - presentation/
        - screens/home_page.dart           # App shell + easter egg trigger
        - widgets/dynamic_ui_builder.dart  # JSON → Widgets
        - widgets/app_bar_actions.dart     # Save/Reset/Undo/Redo
        - widgets/new_input_fab.dart       # Prompt entry
      - domain/mocks/ui_json_mocks.dart    # Curated create/update JSON mocks
    - easter_egg/
      - domain/providers/app_theme_provider.dart  # Theme state (mode, fonts, seed color)
  - core/design_system/
    - widgets/…                           # DS components (TextDS, ContainerDS, etc.)
  - services/ai_service/
    - ai_service.dart                      # Interface
    - firebase_ai_service.dart             # Optional LLM backend (Gemini via Firebase)
    - ai_prompts.dart                      # Prompt templates
  - theme.dart                             # Material 3 helpers (from seed)
  - main.dart                              # App entry, MaterialApp
  - util.dart                              # Safe Google Fonts loading (with fallbacks)

## Design system JSON (mini‑spec)

Every node is:

```json
{
  "type": "string",
  "props": { /* object? */ },
  "children": [ /* Node[]? */ ]
}
```

Supported types: container, row, column, text, icon, image, sizedBox, elevatedButton, textField, expanded, flexible, scroll, padding, checkbox.

Examples
- Container with themed color

```json
{
  "type": "container",
  "props": {
    "decoration": {
      "variant": "primaryContainer",   
      "borderRadius": {"all": 12}
    },
    "padding": {"all": 12}
  },
  "children": [{"type": "text", "props": {"value": "Card title"}}]
}
```

- Scroll wrapper (single child)

```json
{"type": "scroll", "children": [{"type": "column", "props": {"spacing": 12}, "children": [ ]}]}
```

- Flexible row children

```json
{"type":"row","props":{"spacing":12},"children":[{"type":"flexible","props":{"flex":1},"children":[{"type":"text","props":{"value":"Left"}}]},{"type":"flexible","props":{"flex":1},"children":[{"type":"text","props":{"value":"Right"}}]}]}
```

Tip: Avoid hard‑coded colors and font families unless necessary; the theme will shine more when widgets pick from ColorScheme and TextTheme.

## Building with LLMs (the bonus path)

This project ships with an optional Firebase Generative AI backend that can:
- Create UI JSON from text
- Update existing JSON from text
- Generate theme specs (mode, baseColor, fonts)

Enabling it (optional)
1) Ensure your firebase_options.dart is present (already included in this repo).
2) Add Google AI key to your Firebase app if required by your setup.
3) iOS: run `pod install` inside ios/ after `flutter pub get`.
4) Android: Gradle will fetch deps on `flutter run`.


Security
- No secrets are printed. If you add env vars/API keys, prefer secure storage and never echo keys in scripts.

## Testing

Run all tests

```bash
flutter test
```

Widget tests
- Validate that Text, Icon, Image, ElevatedButton, TextField render properly from representative JSON.
- Ensure scroll/padding wrappers wrap single child correctly.

Integration test (example)
- Pumps the app, taps the FAB, selects a “Create login screen” suggestion, submits, and asserts on visible widgets.

Run integration tests on a device/emulator

```bash
flutter test integration_test
```

## Troubleshooting

- “Font not found” errors
  - We now use a safe loader with fallbacks (Inter for body, Bebas Neue for display). Unknown font families won’t crash the app.
- Theme not changing with AI
  - We accept both the new seed‑based schema {mode, baseColor, bodyFont, displayFont} and the legacy one with a colors map. If baseColor is missing, we derive a seed from colors.primary when available.
- iOS build issues after adding packages
  - Run `cd ios && pod install && cd ..` then `flutter clean && flutter pub get`.
- Android emulator shows a blank screen on first run
  - Try `flutter clean && flutter pub get && flutter run -v` and watch the logs.

## Why this showcases LLM‑accelerated dev

- Rapid scaffolding: JSON mocks, DS components, and prompt handlers co‑designed with an AI assistant.
- Iterative reasoning: moved to seed‑based theming, added AI theme generation, made the UI consume theme more deeply — live.
- Guardrails: tests, fallbacks (fonts, legacy AI schema), and quick feedback loops.

## Make it your own

- Add a new DS widget (e.g., slider, chip)
- Teach the updater new linguistic tricks
- Wire a different LLM provider
- Persist favorite UIs and theme combos

Have fun — and long‑press that title once in a while.
