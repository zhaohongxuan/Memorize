//
//  MemorizeApp.swift
//  Memorize
//
//  Created by xuan on 2021/5/31.
//

import SwiftUI

@main
struct MemorizeApp: App {
    var body: some Scene {
        let game = EmojiMemoryGame()
        WindowGroup {
            EmojiMemoryGameView(game: game)
        }
    }
}
