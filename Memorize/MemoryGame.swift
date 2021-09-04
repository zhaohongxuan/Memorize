//
//  MemoryGame.swift
//  Memorize
//
//  Created by xuan on 2021/6/1.
//

import Foundation

struct MemoryGame<CardContent> where CardContent:Equatable {
  
    
    private(set) var cards: Array<Card>
    
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
                if(cards[choseIndex].content == cards[potentialMatchedIndex].content){
                    cards[choseIndex].isMatched = true
                    cards[potentialMatchedIndex].isMatched = true
                }
                cards[choseIndex].isFaceUp = true
            }else{
                indexOfTheOnlyFaceUpCard = choseIndex
            }
        }
    }
    
    init(numberOfPairsOfCards:Int, createCardContent: (Int)->CardContent) {
        cards = []
        for index in 0..<numberOfPairsOfCards{
            let content = createCardContent(index)
            cards.append(Card(content: content,id: index*2 ))
            cards.append(Card(content: content ,id: index*2+1))

        }
    }
    

    
    struct Card : Identifiable{
        var isFaceUp = false
        var isMatched = false
        var content: CardContent
        var id: Int
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
