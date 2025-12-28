//
//  MemorizeTests.swift
//  MemorizeTests
//
//  Created by xuan on 2021/5/31.
//

import XCTest
@testable import Memorize

final class MemorizeTests: XCTestCase {

    func testMemoryGameTacksScoreAndMismatches() {
        var game = MemoryGame(numberOfPairsOfCards: 2) { index in
            return index == 0 ? "🚗" : "🚀"
        }
        guard
            let firstCar = game.cards.first(where: { $0.content == "🚗" }),
            let firstRocket = game.cards.first(where: { $0.content == "🚀" }),
            let secondCar = game.cards.last(where: { $0.content == "🚗" })
        else {
            XCTFail("Unable to create deterministic deck")
            return
        }
        game.choose(firstCar)
        game.choose(firstRocket)
        XCTAssertEqual(game.mismatchCount, 1)
        game.choose(secondCar)
        game.choose(firstCar)
        XCTAssertEqual(game.score, 1, "Matching pair should bump the score")
    }

    func testSessionManagerAdvancesAndAwardsStars() {
        let manager = GameSessionManager()
        XCTAssertEqual(manager.currentLevel.levelNumber, 1)
        XCTAssertTrue(manager.advance(stats: LevelStats(mismatches: 0)))
        XCTAssertEqual(manager.currentLevel.levelNumber, 2)
        XCTAssertEqual(manager.earnedStars, 3)
        XCTAssertTrue(manager.advance(stats: LevelStats(mismatches: 3)))
        XCTAssertEqual(manager.earnedStars, 5)
    }

    func testEmojiMemoryGameLevelProgressionAndRestart() {
        let viewModel = EmojiMemoryGame()
        let originalLevel = viewModel.levelNumber
        XCTAssertTrue(viewModel.advanceLevel())
        XCTAssertEqual(viewModel.levelNumber, originalLevel + 1)
        viewModel.restartJourney()
        XCTAssertEqual(viewModel.levelNumber, 1)
    }

    func testDeckSizesFollowLevelConfigs() {
        let customLevels = [
            LevelConfig(levelNumber: 1, themeID: .friendlyCars, pairCount: 2, bonusTimeLimit: 8, specialRules: [], title: "Mini Cars"),
            LevelConfig(levelNumber: 2, themeID: .rainbowNumbers, pairCount: 3, bonusTimeLimit: 7, specialRules: [], title: "Mini Numbers")
        ]
        let session = GameSessionManager(levels: customLevels)
        let viewModel = EmojiMemoryGame(sessionManager: session, devicePairLimit: 3)
        XCTAssertEqual(viewModel.cards.count, 6)
        XCTAssertTrue(viewModel.advanceLevel())
        XCTAssertEqual(viewModel.cards.count, 6)
    }

    func testReplayAndRestartJourneyProduceFreshDecks() {
        let customLevels = [
            LevelConfig(levelNumber: 1, themeID: .friendlyCars, pairCount: 2, bonusTimeLimit: 8, specialRules: [], title: "Mini Cars"),
            LevelConfig(levelNumber: 2, themeID: .rainbowNumbers, pairCount: 3, bonusTimeLimit: 7, specialRules: [], title: "Mini Numbers")
        ]
        let session = GameSessionManager(levels: customLevels)
        let viewModel = EmojiMemoryGame(sessionManager: session, devicePairLimit: 3)
        let initialScore = viewModel.score
        viewModel.restartLevel()
        XCTAssertEqual(viewModel.cards.count, 6)
        XCTAssertEqual(viewModel.score, initialScore)
        XCTAssertTrue(viewModel.advanceLevel())
        viewModel.restartJourney()
        XCTAssertEqual(viewModel.levelNumber, 1)
        XCTAssertEqual(viewModel.cards.count, 6)
    }

    func testDevicePairLimitStaysConsistentAcrossLevels() {
        CardDensityAdvisor.overridePairLimit = 4
        defer { CardDensityAdvisor.overridePairLimit = nil }
        let viewModel = EmojiMemoryGame()
        XCTAssertEqual(viewModel.cards.count, 8)
        XCTAssertTrue(viewModel.advanceLevel())
        XCTAssertEqual(viewModel.cards.count, 8)
    }
}
