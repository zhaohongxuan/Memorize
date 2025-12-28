import UIKit

/// Calculates how many card pairs the current device can comfortably display without forcing taps on tiny hit targets.
struct CardDensityAdvisor {
    /// Allows unit tests to deterministically pin a device class without relying on simulator geometry.
    static var overridePairLimit: Int?
    
    static func devicePairLimit() -> Int {
        if let override = overridePairLimit {
            return max(1, override)
        }
        #if os(iOS)
        let idiom = UIDevice.current.userInterfaceIdiom
        if idiom == .pad {
            return 10
        }
        let bounds = UIScreen.main.bounds
        let longestSide = max(bounds.width, bounds.height)
        switch longestSide {
        case ..<650:
            return 5
        case ..<780:
            return 6
        case ..<900:
            return 7
        default:
            return 8
        }
        #else
        return 8
        #endif
    }
    
    static func pairCount(for level: LevelConfig, deviceLimit: Int? = nil) -> Int {
        let limit = deviceLimit ?? devicePairLimit()
        let theme = ThemeLibrary.theme(for: level.themeID)
        return max(1, min(limit, theme.content.count))
    }
}
