import Foundation
import Combine

struct LevelConfig: Identifiable, Equatable {
    enum SpecialRule: String {
        case mismatchHint
        case randomShuffle
    }
    let id = UUID()
    let levelNumber: Int
    let themeID: ThemeLibrary.ThemeID
    let pairCount: Int
    let bonusTimeLimit: TimeInterval
    let specialRules: [SpecialRule]
    let title: String
    
    static func defaultCampaign() -> [LevelConfig] {
        [
            LevelConfig(levelNumber: 1, themeID: .friendlyCars, pairCount: 4, bonusTimeLimit: 8, specialRules: [.mismatchHint], title: "Friendly Cars"),
            LevelConfig(levelNumber: 2, themeID: .rainbowNumbers, pairCount: 5, bonusTimeLimit: 7, specialRules: [], title: "Rainbow Numbers"),
            LevelConfig(levelNumber: 3, themeID: .letterLab, pairCount: 6, bonusTimeLimit: 6, specialRules: [], title: "Letter Lab"),
            LevelConfig(levelNumber: 4, themeID: .tinyWords, pairCount: 7, bonusTimeLimit: 6, specialRules: [.randomShuffle], title: "Tiny Words"),
            LevelConfig(levelNumber: 5, themeID: .adventureMix, pairCount: 8, bonusTimeLimit: 5, specialRules: [.randomShuffle], title: "Adventure Mix")
        ]
    }
}

struct LevelStats {
    var mismatches: Int
}

final class GameSessionManager: ObservableObject {
    @Published private(set) var currentLevelIndex: Int = 0
    @Published private(set) var earnedStars: Int = 0
    private(set) var levels: [LevelConfig]
    
    init(levels: [LevelConfig] = LevelConfig.defaultCampaign()) {
        self.levels = levels
    }
    
    var currentLevel: LevelConfig {
        levels[currentLevelIndex]
    }
    
    var progressFraction: Double {
        guard !levels.isEmpty else { return 0 }
        return Double(currentLevelIndex) / Double(levels.count)
    }
    
    var totalLevels: Int {
        levels.count
    }

    var isOnFinalLevel: Bool {
        currentLevelIndex >= levels.count - 1
    }
    
    func restartJourney() {
        currentLevelIndex = 0
        earnedStars = 0
    }
    
    @discardableResult
    func advance(stats: LevelStats) -> Bool {
        earnedStars += starRating(for: stats)
        guard !isOnFinalLevel else { return false }
        currentLevelIndex += 1
        return true
    }
    
    func starRating(for stats: LevelStats) -> Int {
        switch stats.mismatches {
        case Int.min...1:
            return 3
        case 2...3:
            return 2
        default:
            return 1
        }
    }
}
