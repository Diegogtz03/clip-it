//
//  SwiftUIView.swift
//  
//
//  Created by Diego Gutierrez on 25/01/24.
//

import SwiftUI

struct CasseteInset: View {
    var amountOfStreaks = 6
    
    var body: some View {
        ZStack(alignment: .center) {
            Circle()
                .fill(Color(red: 0, green: 0, blue: 0, opacity: 0.5))
                .stroke(.black, lineWidth: 4)
            
            CircularLayout(radius: 20, count: amountOfStreaks)
                .frame(width: 40, height: 40)
        }
    }
}

struct CircularLayout : View {
    var radius: CGFloat;
    var count: Int;

    var body: some View {
      let angle = 2.0 / CGFloat(self.count) * .pi
        return ZStack {
            ForEach((0...count - 1), id: \.self) { index in
                Rectangle()
                    .fill(.black)
                    .frame(width: 7, height: 13)
                    .rotationEffect(Angle(degrees: Double((360 / count) * index * -1) + 90))
                    .position(x: self.radius + cos(angle * CGFloat(index)) * self.radius,
                              y: self.radius - sin(angle * CGFloat(index)) * self.radius)
            }
        }
    }
}

#Preview {
    CasseteInset()
}
