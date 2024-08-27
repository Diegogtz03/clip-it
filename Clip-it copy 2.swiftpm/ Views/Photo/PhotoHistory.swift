//
//  SwiftUIView.swift
//  
//
//  Created by Diego Gutierrez on 09/02/24.
//

import SwiftUI

struct PhotoHistory: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State var photoClip: PhotoClip
    @State var deleteHaptic = false
    
    @State var isZoomedIn: Bool? = false
    
    var dataManager = DataManager()
    
    func formatDateKey(date: Date) -> String {
        let givenComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        let givenDate = Calendar.current.date(from: givenComponents)!
        
        let todayComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        let todayDate = Calendar.current.date(from: todayComponents)!
        
        if (givenDate == todayDate) {
            return "Today"
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE MMM d"
        
        return dateFormatter.string(from: givenDate)
    }
    
    func getImageURL(photoURL: String) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent(photoURL)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(colorScheme == .dark ? "GrainyBackground" : "GrainyBackgroundLight")
                    .resizable()
                    .ignoresSafeArea()
                    .ignoresSafeArea(.keyboard)
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea(.keyboard)
                
                Button {
                    withAnimation {
                        isZoomedIn = false
                    }
                    
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15)
                        .bold()
                        .foregroundStyle(colorScheme == .dark ? .white : .gray)
                        .padding()
                        .padding([.leading], 15)
                }
                .position(x: 30, y: 20)
                
                VStack {
                    HStack {
                        Spacer()
                        
                        Text(formatDateKey(date:photoClip.date))
                            .bold()
                            .font(Font.system(.largeTitle))
                            .foregroundStyle(.gray)
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    PhotoCardStatic(photoFileName: photoClip.url, photoClipNote: photoClip.note, isZoomedIn: $isZoomedIn, isHistory: true)
                        .scaleEffect(1.1)
                    
                    Spacer()
                    
                    HStack {
                        Button() {
                            dataManager.deleteComboPhotoclip(photoURL: photoClip.url, photoClip: photoClip, modelContext: modelContext)
                            
                            deleteHaptic.toggle()
                            
                            dismiss()
                        } label: {
                            Image(systemName: "trash.fill")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(.red)
                                .frame(width: 25)
                        }
                        .sensoryFeedback(.success, trigger: deleteHaptic)
                        
                        Spacer()
                        
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25)
                            .hidden()
                        
                        Spacer()
                        
                        ShareLink(item: getImageURL(photoURL: photoClip.url), subject: Text("Clip-it Photo"), label: {
                            Image(systemName: "square.and.arrow.up")
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(.blue)
                                .frame(width: 25)
                        })
                    }
                    .padding([.leading, .trailing], 45)
                }
                .navigationBarBackButtonHidden()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

#Preview {
    PhotoHistory(photoClip: .init(id: UUID(), date: Date(), note: "", url: ""))
}
