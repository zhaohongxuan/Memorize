//
//  Cardify.swift
//  Memorize
//
//  Created by hank.zhao on 2021/9/5.
//

import SwiftUI

struct Cardify: AnimatableModifier{

//    var isFaceUp:Bool
    
    init(isFaceUp:Bool){
        rotation = isFaceUp ? 0 : 180
    }
    
    var animatableData: Double{
        get{ rotation}
        set{ rotation = newValue}
    }
    
    var rotation:Double
    
    
    func body(content: Content) -> some View {
        ZStack{
            let shape = RoundedRectangle(cornerRadius: DrawingConstants.cornerRadius)
            if rotation < 90 {
                shape.fill().foregroundColor(.white)
                shape.strokeBorder(lineWidth: DrawingConstants.lineWidth)
            }else{
                shape.fill()
            }
            content.opacity(rotation < 90 ? 1: 0)
        }.rotation3DEffect(Angle.degrees(rotation), axis: (0, 1, 0))
    }
    
    
    private struct DrawingConstants {
        static let cornerRadius: CGFloat = 20
        static let lineWidth: CGFloat = 3
    }
}

extension View{
    func cardify(isFaceUp:Bool) -> some View {
        return self.modifier(Cardify(isFaceUp:isFaceUp))
    }
}
