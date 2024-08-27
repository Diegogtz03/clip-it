//
//  SwiftUIView.swift
//
//
//  Created by Diego Gutierrez on 09/02/24.
//

import SwiftUI

struct PhotoCardStatic: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    @State var photoFileName: String
    @State var photoClipNote: String
    @State var finalPhotoFile = ""
    @State private var previewPhoto: Image?
    
    @Binding var isZoomedIn: Bool?
    @State var isHistory: Bool?
    
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
                    if (!(isHistory ?? false)) {
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
                        finalPreview
                            .resizable()
                            .scaledToFill()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .frame(width: !(isZoomedIn ?? false) ? photoCardWidth - 40 : photoCardWidth * 2 , height: !(isZoomedIn ?? false) ? photoCardHeight - 120 : photoCardHeight)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding([.top], 25)
                            .padding([.bottom], 2)
//                            .onTapGesture {
//                                withAnimation {
//                                    isZoomedIn?.toggle()
//                                }
//                            }
                    }
                } else {
                    Image(systemName: "circle.dotted")
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(width: photoCardWidth - 40 , height: photoCardHeight - 120)
                        .padding(25)
                }
                
                Text(photoClipNote)
                    .frame(width: photoCardWidth - 50, alignment: .leading)
                    .foregroundStyle(colorScheme == .dark ? .black : .white)
                    .font(Font.system(.title3))
                    .padding(5)
            }
            .onAppear {
                if let loadedPreview = loadImage() {
                    previewPhoto = Image(uiImage: loadedPreview)
                }
                if (isHistory ?? false) {
                    if (verticalSizeClass == .regular && horizontalSizeClass == .regular) {
                        photoCardWidth = photoCardWidth * 1.3
                        photoCardHeight = photoCardWidth * 1.3
                    }
                }
            }
        }
    }
}

#Preview {
    PhotoCardStatic(photoFileName: "", photoClipNote: "", isZoomedIn: .constant(false))
}
