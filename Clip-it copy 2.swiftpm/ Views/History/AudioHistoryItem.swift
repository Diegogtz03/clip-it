//
//  SwiftUIView.swift
//  
//
//  Created by Diego Gutierrez on 04/02/24.
//

import SwiftUI

struct AudioHistoryItem: View {
    @Environment(\.colorScheme) var colorScheme
    @State var audio: AudioRecording
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(colorScheme == .dark ? Color(red: 0.85, green: 0.85, blue: 0.85) : Color(red: 0.34, green: 0.34, blue: 0.34))
            
            VStack {
                if (audio.note != "") {
                    Text(audio.note)
                        .font(Font.system(.title3))
                        .foregroundStyle(colorScheme == .dark ? .black : .white)
                        .frame(width: 180, alignment: .leading)
                        .padding([.top], 13)
                        .padding([.leading, .trailing], 30)
                    
                    Spacer()
                }
                
                Image("Cassette")
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(audio.note != "" ? 0.5 : 0.8)
                    .shadow(color: colorScheme == .dark ? .black : .white, radius: 4)
            }
        }
        .frame(width: 200, height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 8.0))
        .padding(15)
    }
}

#Preview {
    AudioHistoryItem(audio: .init(id: UUID(), date: Date(), note: "", url: ""))
}
