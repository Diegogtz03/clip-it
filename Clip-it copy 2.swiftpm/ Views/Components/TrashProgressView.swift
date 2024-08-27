//
//  SwiftUIView.swift
//  
//
//  Created by Diego Gutierrez on 02/02/24.
//

import SwiftUI

struct TrashProgessView: View {
    @Binding var progress: Double
    @State var offset = 100.0
    
    var body: some View {
        ZStack {
            Image(systemName: "trash")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.gray)
                .frame(width: 25, height: 25)
            Circle()
                .trim(from:0, to: 0.85)
                .stroke(Color.gray.opacity(0.5), style: StrokeStyle(
                    lineWidth: 6,
                    lineCap: .round
                ))
                .rotationEffect(.degrees(113))
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.white,
                    style: StrokeStyle(
                        lineWidth: 6,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(113))
        }
        .frame(width: 60, height: 60)
        .offset(y: offset)
        .onAppear() {
            withAnimation {
                offset = 0.0
            }
        }
        .onDisappear() {
            withAnimation {
                offset = 150.0
            }
        }
    }
}

#Preview {
    TrashProgessView(progress: .constant(0.0))
}
