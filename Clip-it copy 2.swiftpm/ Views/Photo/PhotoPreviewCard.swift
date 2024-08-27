//
//  SwiftUIView.swift
//  
//
//  Created by Diego Gutierrez on 08/02/24.
//

import SwiftUI

struct PhotoPreviewCard: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @Binding var photoFileName: String
    @Binding var photoNote: String
    @FocusState var areaIsFocused: Bool
    @State var finalPhotoFile = ""
    @State private var previewPhoto: Image?
    
    @State var photoCardWidth = 330.0
    @State var photoCardHeight = 360.0
    
    func loadImage() -> UIImage? {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let photoURL = documentDirectory.appendingPathComponent(photoFileName)
        return UIImage(contentsOfFile: photoURL.path)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 15)
                .fill(colorScheme == .dark ? Color(red: 0.85, green: 0.85, blue: 0.85) : Color(red: 0.29, green: 0.29, blue: 0.29))
                .frame(width: photoCardWidth, height: photoCardHeight)
            
            RoundedRectangle(cornerRadius: 10)
                .fill(.white)
                .frame(width: photoCardWidth - 40, height: photoCardHeight - 120)
                .padding(25)
            
            VStack {
                if let finalPreview = previewPhoto {
                    finalPreview
                        .resizable()
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(width: photoCardWidth - 40 , height: photoCardHeight - 120)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding([.top], 25)
                        .padding([.bottom], 2)
                } else {
                    Image(systemName: "circle.dotted")
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(width: photoCardWidth - 40 , height: photoCardHeight - 120)
                        .padding(25)
                }
                
                
                
                TextField("Write a note...", text: $photoNote, prompt: Text("Write a note...").foregroundStyle(.gray), axis: .vertical)
                    .frame(width: photoCardWidth - 40)
                    .foregroundStyle(colorScheme == .dark ? .black : .white)
                    .font(Font.system(.title2))
                    .padding(5)
                    .focused($areaIsFocused)
                    .onTapGesture {
                        areaIsFocused = true
                    }
            }
            .onAppear {
                if let loadedPreview = loadImage() {
                    previewPhoto = Image(uiImage: loadedPreview)
                }
                
                if (verticalSizeClass == .regular && horizontalSizeClass == .regular) {
                    photoCardWidth = photoCardWidth * 1.3
                    photoCardHeight = photoCardWidth * 1.3
                }
            }
        }
    }
}

#Preview {
    PhotoPreviewCard(photoFileName: .constant(""), photoNote: .constant(""))
}
