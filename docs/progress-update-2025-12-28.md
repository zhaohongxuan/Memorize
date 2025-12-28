# Memorize Progress Report — 2025-12-28

## Highlights
- Level system (`LevelSystem.swift`) now powers sequential campaigns: stars accrue per level, decks re-seed automatically, and the UI reflects current theme/palette.
- `ThemeLibrary.swift` curates transport, number, letter, and word sets with kid-friendly palettes; raising the minimum deployment target to iOS 15 allows us to lean on modern SwiftUI visuals.
- View refresh issues after advancing/replaying levels were fixed by rebuilding the underlying `MemoryGame` each time, so every stage now loads the correct pair count.
- `AspectVGrid.swift` uses dynamic width calculations to keep every card visible without dangling rows, preventing cards from “overflowing” between levels.
- Added regression tests (`MemorizeTests.swift`) to lock in scoring, session progression, deck sizing, and restart semantics.

## Known Issues / Follow Up
1. `xcodebuild test -scheme Memorize` still aborts early with Xcode’s scheme warning (IDESchemeActionResultOperation). Tests pass when run inside Xcode, but we should keep an eye on CI once configured.
2. Celebration overlay flows are basic; when the final level ends we immediately restart the journey. Consider a dedicated “Adventure Complete” screen.
3. Audio/scene assets referenced in themes are placeholders—no actual SFX hooks exist yet.

## Next Suggested Steps
1. Hook the `soundEffectName` metadata into a lightweight audio player so matches trigger kid-friendly cues per theme.
2. Add a level-picker/timeline so parents can jump directly to specific learning domains.
3. Flesh out UI tests to cover overlay transitions and the new control bar actions once the simulator issue is resolved.
