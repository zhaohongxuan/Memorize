import SwiftUI

struct ThemePalette {
    let primary: Color
    let secondary: Color
    let background: Color
}

struct GameTheme: Identifiable {
    enum ContentKind {
        case emoji
        case number
        case letter
        case word
    }
    let id: ThemeLibrary.ThemeID
    let displayName: String
    let content: [String]
    let contentKind: ContentKind
    let difficultyTag: String
    let palette: ThemePalette
    let soundEffectName: String?
}

enum ThemeLibrary {
    enum ThemeID: String, CaseIterable {
        case friendlyCars
        case rainbowNumbers
        case letterLab
        case tinyWords
        case adventureMix
        case jungleDiscovery
    }
    
    static let themes: [ThemeID: GameTheme] = {
        var items: [ThemeID: GameTheme] = [:]
        items[.friendlyCars] = GameTheme(
            id: .friendlyCars,
            displayName: "Friendly Cars",
            content: ["🚗","🚕","🚙","🚌","🚎","🏎","🚓","🚑"],
            contentKind: .emoji,
            difficultyTag: "easy",
            palette: ThemePalette(primary: .red, secondary: .orange, background: Color(red: 1.0, green: 0.95, blue: 0.9)),
            soundEffectName: "siren"
        )
        items[.rainbowNumbers] = GameTheme(
            id: .rainbowNumbers,
            displayName: "Rainbow Numbers",
            content: ["0","1","2","3","4","5","6","7","8","9"],
            contentKind: .number,
            difficultyTag: "easy",
            palette: ThemePalette(primary: .blue, secondary: .purple, background: Color(red: 0.9, green: 0.95, blue: 1.0)),
            soundEffectName: "chime"
        )
        items[.letterLab] = GameTheme(
            id: .letterLab,
            displayName: "Letter Lab",
            content: ["A","B","C","D","E","F","G","H","I","J","K","L"],
            contentKind: .letter,
            difficultyTag: "medium",
            palette: ThemePalette(primary: .green, secondary: Color(red: 0.7, green: 0.95, blue: 0.8), background: Color(red: 0.94, green: 1.0, blue: 0.94)),
            soundEffectName: "sparkle"
        )
        items[.tinyWords] = GameTheme(
            id: .tinyWords,
            displayName: "Tiny Words",
            content: ["cat","sun","map","hat","dog","car","bug","cup"],
            contentKind: .word,
            difficultyTag: "medium",
            palette: ThemePalette(primary: .pink, secondary: .yellow, background: Color(red: 1.0, green: 0.92, blue: 0.96)),
            soundEffectName: "pageFlip"
        )
        items[.adventureMix] = GameTheme(
            id: .adventureMix,
            displayName: "Adventure Mix",
            content: ["🚀","🦊","7","Q","ship","hero","kite","ring"],
            contentKind: .word,
            difficultyTag: "hard",
            palette: ThemePalette(primary: Color(red: 0.3, green: 0.2, blue: 0.6), secondary: Color(red: 0.1, green: 0.5, blue: 0.5), background: Color(red: 0.92, green: 0.93, blue: 1.0)),
            soundEffectName: "whoosh"
        )
        items[.jungleDiscovery] = GameTheme(
            id: .jungleDiscovery,
            displayName: "Jungle Discovery",
            content: ["🦁","🐯","🐵","🦓","🦒","🐼","🦜","🐘"],
            contentKind: .emoji,
            difficultyTag: "easy",
            palette: ThemePalette(primary: Color(red: 0.55, green: 0.35, blue: 0.2), secondary: .green, background: Color(red: 0.93, green: 0.98, blue: 0.9)),
            soundEffectName: "growl"
        )
        return items
    }()
    
    static func theme(for id: ThemeID) -> GameTheme {
        themes[id] ?? themes[.friendlyCars]!
    }
}
