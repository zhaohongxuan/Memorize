# Memorize Upgrade Blueprint

## 1. Goals & Audience
- Keep rounds fast (<2 minutes) with bright feedback so kids stay engaged.
- Introduce progressive difficulty without punitive failure; gently ramp complexity and deck size.
- Reinforce learning domains (transport, numbers, letters, vocabulary) so parents can pick educational focus.

## 2. Level Progression
- Define `LevelConfig` (levelNumber, pairCount, contentKind, timeAllowance, specialRules).
- After every win, instantiate the next `LevelConfig`; increase challenge via: more pairs, new symbol sets, shorter bonus timers, distraction mechanics (dummy cards or shuffles).
- Sample progression:
  | Level | Theme          | Pairs | Bonus Limit | Notes |
  |-------|----------------|-------|-------------|-------|
  | 1     | Friendly Cars  | 4     | 8 s         | Large cards, hints on mismatch |
  | 2     | Rainbow Numbers| 5     | 7 s         | Introduce digits 0-9 |
  | 3     | Letter Lab     | 6     | 6 s         | Uppercase letters |
  | 4     | Tiny Words     | 7     | 6 s         | Sight words ("cat", "sun") |
  | 5     | Adventure Mix  | 8     | 5 s         | Mixed content + random shuffle events |

## 3. Content Library
- Create `GameTheme` struct (id, displayName, content: [String], difficultyTag, palette, sfxName).
- Buckets to pre-fill:
  1. Emoji (vehicles, animals, foods) → tactile, low reading level.
  2. Numbers (0-9, simple math expressions) → reinforce counting.
  3. Letters (uppercase, lowercase, digraphs) → phonics practice.
  4. Words (CVC words, rhyming pairs, themed nouns) → reading confidence.
- Keep assets in `ThemeLibrary.swift`; expose helper `defaultSequence(for ageRange:)` to auto-pick a level pipeline.

## 4. Kid-Friendly Scenes
- "City Helpers": cards show service vehicles; background skyline, siren chimes on match.
- "Jungle Discovery": animal emojis + leafy gradient; correct match triggers animal growl.
- "Number Rocket": digits as astronauts; progress bar styled as rocket fuel.
- "Storybook Camp": short words on fabric textures; campfire crackle loop after win.
- Each scene maps to theme metadata (colors, sfx) so `EmojiMemoryGameView` can skin UI dynamically per level.

## 5. Architecture Changes
- Keep MVVM but add two coordinators:
  - `GameSessionManager`: owns `[LevelConfig]`, current level index, cumulative stars; tells `EmojiMemoryGame` when to re-seed model.
  - `ThemeLibrary`: static provider returning `GameTheme`s + convenience selectors.
- Model (`MemoryGame`):
  - Add `init(cards: [Card])` overload so session manager can pre-build shuffled decks per level.
  - Track `mismatches` or `streaks` if later scoring tiers needed.
- ViewModel (`EmojiMemoryGame`):
  - Inject `GameSessionManager`; expose `levelInfo`, `progressFraction`, `sceneAssets`.
  - Add `advanceLevel()` hook that resets `game` with next `LevelConfig` inside `withAnimation`.
- Views:
  - Wrap existing board in `LevelHUD` showing level badge, theme icon, progress bar.
  - Celebration overlay should branch: show stars earned, CTA `Next Adventure` (calls `advanceLevel`).
  - Add gentle tutorial callouts on early levels (SwiftUI `@State` toggles).

## 6. Prompt for AI Builders
```
You are upgrading the SwiftUI Memorize game (MVVM, files under `Memorize/`). Goals: multi-level progression, kid-friendly themes, broader content types. Implement:
1. `ThemeLibrary` + `GameTheme` describing id, name, emojis/strings, palette, sfx.
2. `LevelConfig` + `GameSessionManager` that sequences levels, tells `EmojiMemoryGame` when to reload decks, and tracks stars.
3. Extend `MemoryGame` initializers and scoring to accept externally-built decks and variable bonus timers.
4. Update `EmojiMemoryGame` & `EmojiMemoryGameView` to display level HUD, theme-driven styling, and `Next Adventure` overlay.
Keep logic in model, orchestration in view model, animations in SwiftUI views. Use `withAnimation` around user-driven mutations. Add unit tests for new session logic.
```
