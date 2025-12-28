//
//  EmojiMemoryGame.swift
//  Memorize
//
//  Created by xuan on 2021/6/1.
//

import SwiftUI

class EmojiMemoryGame:ObservableObject {
    @Published private var game: MemoryGame<String>
    
    private let sessionManager: GameSessionManager
    private let devicePairLimit: Int
    private var activeLevel: LevelConfig
    private var activeTheme: GameTheme {
        ThemeLibrary.theme(for: activeLevel.themeID)
    }
    
    init(sessionManager: GameSessionManager = GameSessionManager(), devicePairLimit: Int? = nil) {
        self.sessionManager = sessionManager
        self.activeLevel = sessionManager.currentLevel
        self.devicePairLimit = devicePairLimit ?? CardDensityAdvisor.devicePairLimit()
        self.game = EmojiMemoryGame.makeGame(for: sessionManager.currentLevel, devicePairLimit: self.devicePairLimit)
    }
    
    var cards:Array<MemoryGame<String>.Card>{
        return game.cards
    }
    
    var score: Int {
        game.score
    }
    
    var isGameOver: Bool {
        game.cards.allSatisfy { $0.isMatched }
    }
    
    var levelTitle: String {
        activeLevel.title
    }
    
    var levelNumber: Int {
        activeLevel.levelNumber
    }
    
    var palette: ThemePalette {
        activeTheme.palette
    }
    
    var themeName: String {
        activeTheme.displayName
    }
    
    var progressFraction: Double {
        guard totalLevels > 0 else { return 0 }
        return Double(levelNumber) / Double(totalLevels)
    }
    
    var totalLevels: Int {
        sessionManager.totalLevels
    }

    var isOnFinalLevel: Bool {
        sessionManager.isOnFinalLevel
    }
    
    var earnedStars: Int {
        sessionManager.earnedStars
    }

    var projectedStars: Int {
        sessionManager.starRating(for: LevelStats(mismatches: game.mismatchCount))
    }
    
    var mismatchCount: Int {
        game.mismatchCount
    }
    
    func choose(_ card:MemoryGame<String>.Card){
        game.choose(card)
        scheduleMatchedCardsFlipDown()
    }
    
    func shuffle(){
        game.shuffle()
    }
    
    func flipCardBack(_ card: MemoryGame<String>.Card) {
        game.flipCardBack(card)
    }

    func restartLevel() {
        reloadActiveLevel()
    }
    
    func restartJourney() {
        sessionManager.restartJourney()
        activeLevel = sessionManager.currentLevel
        reloadActiveLevel()
    }
    
    @discardableResult
    func advanceLevel() -> Bool {
        let stats = LevelStats(mismatches: game.mismatchCount)
        let moved = sessionManager.advance(stats: stats)
        if moved {
            activeLevel = sessionManager.currentLevel
            reloadActiveLevel()
        }
        return moved
    }

    private func reloadActiveLevel() {
        game = EmojiMemoryGame.makeGame(for: activeLevel, devicePairLimit: devicePairLimit)
    }
    
    private static func makeGame(for level: LevelConfig, devicePairLimit: Int) -> MemoryGame<String> {
        MemoryGame(cards: buildDeck(for: level, devicePairLimit: devicePairLimit))
    }
    
    private static func buildDeck(for level: LevelConfig, devicePairLimit: Int) -> [MemoryGame<String>.Card] {
        let theme = ThemeLibrary.theme(for: level.themeID)
        let actualPairCount = CardDensityAdvisor.pairCount(for: level, deviceLimit: devicePairLimit)
        let usableContent = Array(theme.content.shuffled().prefix(actualPairCount))
        var cards: [MemoryGame<String>.Card] = []
        for symbol in usableContent {
            let firstCard = MemoryGame<String>.Card(content: symbol, bonusTimeLimit: level.bonusTimeLimit)
            let secondCard = MemoryGame<String>.Card(content: symbol, bonusTimeLimit: level.bonusTimeLimit)
            cards.append(contentsOf: [firstCard, secondCard])
        }
        return cards.shuffled()
    }

    private func scheduleMatchedCardsFlipDown() {
        let matchedFaceUpIDs = game.cards.filter { $0.isMatched && $0.isFaceUp }.map { $0.id }
        guard !matchedFaceUpIDs.isEmpty else { return }
        // Allow spin (starts ~0.5s after flip) + fade (1s) to be visible
        let delay: TimeInterval = 2.1
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self else { return }
            self.game.flipCardsDown(withIDs: matchedFaceUpIDs)
        }
    }
}
