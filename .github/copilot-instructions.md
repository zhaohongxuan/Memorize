# Copilot Instructions

## Project Snapshot
- SwiftUI Memorize memory game targeting iOS only. Open `Memorize.xcodeproj` in Xcode 17, run the `Memorize` scheme, and keep tests under `MemorizeTests/`.
- `MemorizeApp` instantiates a single `EmojiMemoryGame` and injects it into `EmojiMemoryGameView` via `WindowGroup`; no other dependency injection.

## Architecture Map
- Model: `MemoryGame<CardContent>` (`Memorize/MemoryGame.swift`) owns deck state, scoring, mismatch tracking, shuffling, and card bonus timers. `Card.stopUsingBonusTime()` resets `pastFaceUpTime` when an unmatched card flips down but preserves elapsed time for matched cards so fade/spin windows finish.
- ViewModel: `EmojiMemoryGame` (`Memorize/EmojiMemoryGame.swift`) wraps the model, exposes HUD data (score, stars, mismatches, progress) via `GameSessionManager`, and schedules matched cards to flip down 2.1 s after matching (`DispatchQueue.main.asyncAfter`). All user intents eventually call `MemoryGame` mutations.
- Views: `EmojiMemoryGameView` renders the HUD, stats row, `AspectVGrid` of cards, action buttons (shuffle/replay/journey reset), and a celebration overlay. Each `CardView` animates a `Pie` wedge for bonus time, starts a perpetual spin 0.5 s after a match, and fades out over 1 s; a `Timer` publisher flips unmatched cards whose `bonusTimeRemaining` hits zero.
- Layout helpers: `AspectVGrid` enforces the 2:3 card ratio with ≥50 pt width; `Cardify` provides the 3D flip (front shown while rotation <90°); `Pie` animates start/end angles.

## Device & Level Logic
- `CardDensityAdvisor` (`Memorize/CardDensityAdvisor.swift`) clamps pair counts per device (phone tiers 5–8 pairs, iPad 10) using the longest screen edge; override the limit in tests via `overridePairLimit` (always reset with `defer`).
- Decks are built by `EmojiMemoryGame.buildDeck`, which pulls symbols + palettes from `ThemeLibrary` using `LevelConfig.themeID` and applies the current level’s `bonusTimeLimit`. Adjust pair counts or bonuses by editing `LevelConfig`/theme data, not scattered constants.
- `GameSessionManager` tracks `LevelConfig`s, total levels, earned stars, and advancement rules; always call `advanceLevel()` to update both manager and deck, and `restartJourney()` to reset everything.

## UI Behaviors & Conventions
- Wrap taps, shuffles, level restarts, and journey actions in `withAnimation` (existing code uses `.easeInOut(duration: 0.5)`), so mutations stay synchronized with SwiftUI transitions.
- Guard async work with `card.isMatched && card.isFaceUp` to avoid acting on cards that already flipped back due to timers or delays.
- Hide matched-but-face-down cards by rendering `Color.clear`; keep matched-face-up cards visible until the scheduled flip-down so the spin/fade finishes cleanly.
- HUD styling relies on semi-transparent white backgrounds plus palette-colored shadows; keep palette values (`ThemePalette`) as the single truth for colors.

## Testing & Tooling
- Unit coverage lives in `MemorizeTests/MemorizeTests.swift` and verifies scoring/mismatches (`MemoryGame`), session progression (`GameSessionManager`), deck sizing across levels/device limits, and restart freshness. Extend here when adding gameplay or level logic.
- Preferred command-line test run: `xcodebuild test -project Memorize.xcodeproj -scheme Memorize -only-testing:MemorizeTests -destination 'platform=iOS Simulator,name=iPhone 17'`.
- Tests rely on deterministic decks: pass `devicePairLimit` into `EmojiMemoryGame`, inject custom `LevelConfig` arrays, and restore global overrides in a `defer` block to avoid leaking state.

## Extension Patterns
- New themes go into `ThemeLibrary` (`content`, `palette`, `displayName`) and are referenced from `LevelConfig.themeID`; expose them through the session manager rather than hard-coding in the view.
- Gameplay tweaks (scoring, bonus timers, flip logic) belong inside `MemoryGame`; surface any extra UI needs via computed properties on `EmojiMemoryGame` so SwiftUI views remain declarative.
- Layout changes should prefer adjusting `AspectVGrid` (adaptive minimum, spacing) or the shared button styles instead of per-view GeometryReader math.
