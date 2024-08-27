//
//  SwiftUIView.swift
//  
//
//  Created by Diego Gutierrez on 31/01/24.
//

import SwiftUI

struct Icon: Identifiable, Equatable {
    let id: Int
    let size: CGFloat
    let iconName: String
    var transition: Transition
}

struct Transition: Equatable {
    var offset: CGPoint
    let endOffset: CGPoint
}

struct FloatingIcons: View {
    @State var width: CGFloat
    @State var opacity = 0.0
    
    @State private var icons: [Icon] = []
    @State private var counter: Int = 0
    
    let timer = Timer.publish(every: 0.8, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            ForEach(icons) { icon in
                Image(systemName: icon.iconName)
                    .font(.system(size: icon.size))
                    .foregroundColor(Color.gray.opacity(0.8))
                    .offset(x: icon.transition.offset.x, y: icon.transition.offset.y)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            icons.removeAll { $0.id == icon.id }
                        }
                        
                        withAnimation(.easeOut(duration: 2)) {
                            icons = icons.map { currentIcon in
                                if currentIcon.id == icon.id {
                                    var updatedIcon = currentIcon
                                    updatedIcon.transition.offset = icon.transition.endOffset
                                    return updatedIcon
                                }
                                return currentIcon
                            }
                        }
                    }
            }
        }
        .frame(width: width, height: 250)
        .opacity(opacity)
        .mask(LinearGradient(gradient: Gradient(stops: [
            .init(color: .clear, location: 0),
            .init(color: .black, location: 0.10),
            .init(color: .black, location: 0.95),
            .init(color: .clear, location: 1)
        ]), startPoint: .leading, endPoint: .trailing))
        .mask(LinearGradient(gradient: Gradient(stops: [
            .init(color: .clear, location: 0),
            .init(color: .black, location: 0.10),
            .init(color: .black, location: 0.95),
            .init(color: .clear, location: 1)
        ]), startPoint: .top, endPoint: .bottom))
        .onReceive(timer) { _ in
            spawnIcon(width: width)
            spawnIcon(width: width)
            spawnIcon(width: width)
        }
        .onAppear() {
            withAnimation {
                opacity = 1.0
            }
        }
        .onDisappear() {
            withAnimation {
                opacity = 0.0
            }
        }
    }
    
    func spawnIcon(width: CGFloat) {
        let iconNames = ["music.note", "music.quarternote.3", "ear"]
        let randomIconName = iconNames.randomElement() ?? "music.note"
        let randomTransition = generateRandomTransition(width: width)
        let newIcon = Icon(id: counter, size: CGFloat.random(in: 15..<25), iconName: randomIconName, transition: randomTransition)
        icons.append(newIcon)
        counter += 1
    }
    
    func generateRandomTransition(width: CGFloat) -> Transition {
        let cardWidth = width - 60
        let cardHeight = 190.0
    
        let minX = -cardWidth
        let maxX = cardWidth
        let minY = -cardHeight
        let maxY = cardHeight

        let randomX = CGFloat.random(in: minX...maxX)
        let randomY = CGFloat.random(in: minY...maxY)

        let edge = Int.random(in: 1...4)
        let floatingOffset = 30.0;
        
        switch edge {
        case 1: // Top edge
            return Transition(offset: CGPoint(x: randomX, y: -(cardHeight / 2)), endOffset: CGPoint(x: randomX, y: -(cardHeight / 2) - floatingOffset))
        case 2: // Bottom edge
            return Transition(offset: CGPoint(x: randomX, y: cardHeight / 2), endOffset: CGPoint(x: randomX, y: (cardHeight / 2) + floatingOffset))
        case 3: // Left edge
            return Transition(offset: CGPoint(x: -(cardWidth / 2), y: randomY), endOffset: CGPoint(x: -(cardWidth / 2) - floatingOffset, y: randomY))
        default: // Right edge
            return Transition(offset: CGPoint(x: cardWidth / 2, y: randomY), endOffset: CGPoint(x: (cardWidth / 2) + floatingOffset, y: randomY))
        }
    }
}

#Preview {
    FloatingIcons(width: 0.0)
}
