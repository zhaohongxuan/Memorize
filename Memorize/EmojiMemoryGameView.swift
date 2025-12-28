//
//  ContentView.swift
//  Memorize
//
//  Created by xuan on 2021/5/31.
//

import SwiftUI

struct EmojiMemoryGameView: View {
        
    @ObservedObject var game: EmojiMemoryGame
    
    var body: some View {
        ZStack {
            game.palette.background
                .ignoresSafeArea()
            VStack(spacing: 16){
                LevelHUD(levelNumber: game.levelNumber, totalLevels: game.totalLevels, themeName: game.themeName, progress: game.progressFraction, palette: game.palette)
                statsRow
                gameBody
                controlBar
            }
            .padding()
            
            if game.isGameOver {
                celebrationOverlay
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
     
    var gameBody:some View{
        AspectVGrid(items: game.cards, aspectRatio: 2/3 ) { card in
          if card.isMatched && !card.isFaceUp{
              Color.clear
            }else{
                CardView(card: card)
                    .padding(3)
                    .transition(AnyTransition.scale)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.5)){
                            game.choose(card)}
                        }
                    .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
                        if card.isFaceUp && !card.isMatched && card.bonusTimeRemaining == 0 {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                game.flipCardBack(card)
                            }
                        }
                    }
            }
        }
        .foregroundColor(game.palette.primary)
    }
    
    private var statsRow: some View {
        HStack {
            Label("Score: \(game.score)", systemImage: "hand.thumbsup.fill")
            Spacer()
            Label("Stars: \(game.projectedStars)", systemImage: "star.fill")
            Spacer()
            Label("Oops: \(game.mismatchCount)", systemImage: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
        }
        .font(.headline)
    }
    
    private var controlBar: some View {
        HStack(spacing: 12) {
            Button(action: {
                withAnimation {
                    game.shuffle()
                }
            }) {
                Label("Shuffle", systemImage: "shuffle")
            }
            .buttonStyle(PillButtonStyle(color: game.palette.primary))
            
            Button(action: {
                withAnimation {
                    game.restartLevel()
                }
            }) {
                Label("Replay", systemImage: "arrow.counterclockwise")
            }
            .buttonStyle(PillButtonStyle(color: game.palette.secondary))
            
            Button(action: {
                withAnimation {
                    game.restartJourney()
                }
            }) {
                Label("Restart Journey", systemImage: "goforward")
            }
            .buttonStyle(PillButtonStyle(color: .gray))
        }
    }
    
    private var celebrationOverlay: some View {
        VStack(spacing: 16) {
            Text(game.isOnFinalLevel ? "Final Adventure Complete!" : "Level Complete!")
                .font(.title2.bold())
            Text(game.themeName)
                .font(.headline)
            HStack {
                ForEach(0..<3) { index in
                    Image(systemName: index < game.projectedStars ? "star.fill" : "star")
                        .foregroundColor(game.palette.primary)
                }
            }
            Text("Great job! Ready for the next challenge?")
                .font(.subheadline)
                .multilineTextAlignment(.center)
            Button(action: {
                withAnimation {
                    let moved = game.advanceLevel()
                    if !moved {
                        game.restartJourney()
                    }
                }
            }) {
                Text(game.isOnFinalLevel ? "Finish Journey" : "Next Adventure")
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
            }
            .buttonStyle(PillButtonStyle(color: game.palette.primary))
            
            Button(action: {
                withAnimation {
                    game.restartLevel()
                }
            }) {
                Text("Replay Level")
                    .font(.subheadline.bold())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
            }
            .buttonStyle(PillButtonStyle(color: game.palette.secondary))
        }
        .padding(24)
        .background(Color.white.opacity(0.9))
        .cornerRadius(24)
        .shadow(radius: 20)
        .padding()
    }
}


struct CardView: View {

    let card: MemoryGame<String>.Card
    
    @State private var animatedBonusRemaining: Double = 0
    @State private var matchEffectsEnabled: Bool = false
    
    var body: some View{
        GeometryReader { geometry in
            ZStack{
                if card.isFaceUp {
                    Pie(startAngle: Angle(degrees: 0-90), endAngle: Angle(degrees: (1-animatedBonusRemaining)*360-90))
                        .padding(5)
                        .opacity(0.5)
                        .onAppear {
                            animatedBonusRemaining = card.bonusRemaining
                            withAnimation(.linear(duration: card.bonusTimeRemaining)) {
                                animatedBonusRemaining = 0
                            }
                        }
                }
                
                Text(card.content).font(font(in: geometry.size))
                    .rotationEffect(Angle.degrees(matchEffectsEnabled ? 360 : 0))
                    .animation(matchEffectsEnabled ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default, value: matchEffectsEnabled)
                    .font(Font.system(size: DrawingConstants.fontSize))
                    .scaleEffect(scale(thatFits: geometry.size))
        
            }
            .cardify(isFaceUp: card.isFaceUp)
            .opacity(matchEffectsEnabled ? 0 : 1)
            .animation(.easeOut(duration: 1).delay(1.0), value: matchEffectsEnabled)
            .onAppear {
                startBonusAnimation()
                scheduleMatchEffectsIfNeeded()
            }
            .onChange(of: card.isFaceUp) { _ in
                scheduleMatchEffectsIfNeeded()
            }
            .onChange(of: card.isMatched) { _ in
                scheduleMatchEffectsIfNeeded()
            }
        }
    }

    private func startBonusAnimation() {
        animatedBonusRemaining = card.bonusRemaining
        withAnimation(.linear(duration: card.bonusTimeRemaining)) {
            animatedBonusRemaining = 0
        }
    }
    
    private func scheduleMatchEffectsIfNeeded() {
        // Start effects only after the card is face up and matched, giving flip time (~0.5s)
        guard card.isMatched && card.isFaceUp else {
            matchEffectsEnabled = false
            return
        }
        let flipDuration: TimeInterval = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + flipDuration) {
            // Re-check to avoid stale dispatch
            if card.isMatched && card.isFaceUp {
                withAnimation { matchEffectsEnabled = true }
            }
        }
    }
    
    private func scale(thatFits size:CGSize) -> CGFloat{
        min(size.height, size.width) / (DrawingConstants.fontSize / DrawingConstants.fontScale)
    }
    
    private func font(in size: CGSize)-> Font{
        Font.system(size: min( size.width, size.height ) * DrawingConstants.fontScale )
    }
    
    
    private struct DrawingConstants {
        static let fontScale: CGFloat = 0.5
        static let fontSize:CGFloat=45
    }
}

struct LevelHUD: View {
    let levelNumber: Int
    let totalLevels: Int
    let themeName: String
    let progress: Double
    let palette: ThemePalette
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Level \(levelNumber) of \(max(totalLevels, 1))")
                    .font(.headline)
                Spacer()
                Text(themeName)
                    .font(.subheadline)
                    .foregroundColor(palette.primary)
            }
            ProgressView(value: clampedProgress, total: 1.0)
                .accentColor(palette.primary)
            Text("Keep matching to reach the next scene!")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color.white.opacity(0.8))
        .cornerRadius(18)
        .shadow(color: palette.primary.opacity(0.2), radius: 10, x: 0, y: 6)
    }
    
    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }
}

struct PillButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
                    .background(color.opacity(configuration.isPressed ? 0.7 : 1))
            .cornerRadius(12)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = EmojiMemoryGame()
        game.choose(game.cards.first!)
       return  EmojiMemoryGameView(game: game)
    }
}
