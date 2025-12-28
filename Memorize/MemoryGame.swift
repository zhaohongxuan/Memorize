//
//  MemoryGame.swift
//  Memorize
//
//  Created by xuan on 2021/6/1.
//

import Foundation

struct MemoryGame<CardContent> where CardContent:Equatable {
  
    
    private(set) var cards: Array<Card>
    private(set) var score: Int = 0
    private(set) var mismatchCount: Int = 0
    
    private var indexOfTheOnlyFaceUpCard: Int? {
        get{ cards.indices.filter({ cards[$0].isFaceUp }).oneAndOnly  }
        
        set{ cards.indices.forEach({ cards[$0].isFaceUp = ($0 == newValue) }) }
    }

    
    
    mutating func choose(_ card:Card)  {
        // when chose card is not face up and is not matched
        if let choseIndex = cards.firstIndex ( where: {$0.id == card.id}),
           !cards[choseIndex].isFaceUp,
           !cards[choseIndex].isMatched
        {
            if let potentialMatchedIndex = indexOfTheOnlyFaceUpCard{
                cards[choseIndex].isFaceUp = true
                if(cards[choseIndex].content == cards[potentialMatchedIndex].content){
                    cards[choseIndex].isMatched = true
                    cards[potentialMatchedIndex].isMatched = true
                    score += 1
                } else {
                    mismatchCount += 1
                }
            }else{
                indexOfTheOnlyFaceUpCard = choseIndex
            }
        }
    }
    
    init(numberOfPairsOfCards:Int, createCardContent: (Int)->CardContent) {
        cards = []
        for index in 0..<numberOfPairsOfCards{
            let content = createCardContent(index)
            cards.append(Card(content: content))
            cards.append(Card(content: content))

        }
        cards.shuffle()
    }

    init(cards: [Card]) {
        self.cards = cards
    }
    
    mutating func shuffle(){
        cards.shuffle()
    }

    mutating func flipCardsDown(withIDs ids: [Card.ID]) {
        for index in cards.indices where ids.contains(cards[index].id) {
            cards[index].isFaceUp = false
        }
    }
    
    mutating func flipCardBack(_ card: Card) {
        if let index = cards.firstIndex(where: {$0.id == card.id}) {
            if cards[index].isFaceUp && !cards[index].isMatched {
                cards[index].isFaceUp = false
            }
        }
    }

    
    struct Card : Identifiable{
        var isFaceUp = false {
            didSet {
                if isFaceUp {
                    startUsingBonusTime()
                } else {
                    stopUsingBonusTime()
                }
            }
        }
        var isMatched = false {
            didSet {
                stopUsingBonusTime()
            }
        }
        var content: CardContent
        var id: UUID
        
        // MARK: - Bonus Time
        
        var bonusTimeLimit: TimeInterval
        
        private var faceUpTime: TimeInterval {
            if let lastFaceUpDate = self.lastFaceUpDate {
                return pastFaceUpTime + Date().timeIntervalSince(lastFaceUpDate)
            } else {
                return pastFaceUpTime
            }
        }
        
        var lastFaceUpDate: Date?
        var pastFaceUpTime: TimeInterval = 0
        
        var bonusTimeRemaining: TimeInterval {
            max(0, bonusTimeLimit - faceUpTime)
        }
        
        var bonusRemaining: Double {
            (bonusTimeLimit > 0 && bonusTimeRemaining > 0) ? bonusTimeRemaining/bonusTimeLimit : 0
        }
        
        var hasEarnedBonus: Bool {
            isMatched && bonusTimeRemaining > 0
        }
        
        var isConsumingBonusTime: Bool {
            isFaceUp && !isMatched && bonusTimeRemaining > 0
        }
        
        init(content: CardContent, id: UUID = UUID(), bonusTimeLimit: TimeInterval = 6) {
            self.content = content
            self.id = id
            self.bonusTimeLimit = bonusTimeLimit
        }
        
        private mutating func startUsingBonusTime() {
            if isConsumingBonusTime, lastFaceUpDate == nil {
                lastFaceUpDate = Date()
            }
        }
        
        private mutating func stopUsingBonusTime() {
            if isMatched {
                pastFaceUpTime = faceUpTime
            } else {
                pastFaceUpTime = 0
            }
            self.lastFaceUpDate = nil
        }
    }

 
}

extension Array{
 
    var oneAndOnly:Element? {
        if count == 1{
            return first
        }
        return  nil
    }
}
