//
//  EmojiMemoryGame.swift
//  Memorize
//
//  Created by xuan on 2021/6/1.
//

import SwiftUI

class EmojiMemoryGame:ObservableObject {
    static let emojis = ["🚘","🚕","🚀","🚁","🚜","⛵️","🛸","🚛","🚍","🚒","🚂"]
    
    
    static func createMemoryGame()-> MemoryGame<String>{
        MemoryGame<String>(numberOfPairsOfCards: 5){ pairIndex in emojis[pairIndex]}
    }
    
    @Published private var game: MemoryGame<String> = EmojiMemoryGame.createMemoryGame()

    
    var cards:Array<MemoryGame<String>.Card>{
        return game.cards
    }
    
    func choose(_ card:MemoryGame<String>.Card){
        game.choose(card)
    }
}
