//
//  SwiftUIView.swift
//  
//
//  Created by Diego Gutierrez on 09/02/24.
//

import SwiftUI

struct PhotoHistoryItem: View {
    @Environment(\.colorScheme) var colorScheme
    @State var photoClip: PhotoClip
    
    var body: some View {
        ZStack {
//            Rectangle()
//                .fill(colorScheme == .dark ? Color(red: 0.85, green: 0.85, blue: 0.85) : Color(red: 0.34, green: 0.34, blue: 0.34))
            
            PhotoCardStatic(photoFileName: photoClip.url, photoClipNote: photoClip.note, isZoomedIn: .constant(false))
                .scaleEffect(0.5)
                .rotationEffect(.degrees(Double.random(in: -5.0..<5.0)))
        }
        .frame(width: 200, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 8.0))
        .padding(15)
    }
}

#Preview {
    PhotoHistoryItem(photoClip: .init(id: UUID(), date: Date(), note: "", url: ""))
}
