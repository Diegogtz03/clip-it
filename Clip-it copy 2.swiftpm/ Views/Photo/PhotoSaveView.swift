//
//  SwiftUIView.swift
//  
//
//  Created by Diego Gutierrez on 02/02/24.
//

import SwiftUI

struct PhotoSaveView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    @Binding var photoFileName: String
    @Binding var saveIsShown: Bool
    @Binding var viewsIconHidden: Bool
    
    @State var offset = 500.0
    @State var initialOpacity = 0.0
    
    @State var photoNote = ""
    @State var photoDate = Date()
    
    @State var deleteProgress = 0.0
    @State var shadowProgress = 0.0
    @State var deleteIsShown = false
    @State var stage1Haptic = false
    @State var stage2Haptic = false
    @State var stage3Haptic = false
    @State var saveHaptic = false
    @State var deleteHaptic = false
    @State var tapHaptic = false
    
    @State var hasDeleted = false
    @State var hasSaved = false
    
    var dataManager = DataManager()
    
    var savePress: some Gesture {
        DragGesture(minimumDistance: 0.0)
            .onChanged({ _ in
                if (!tapHaptic) {
                    tapHaptic.toggle()
                }
            })
            .onEnded { _ in
                tapHaptic.toggle()
            }
    }
    
    var deleteGesture: some Gesture {
        DragGesture(minimumDistance: 65.0)
            .onChanged { dragValue in
                if (dragValue.translation.height >= 180.0) {
                    if (!stage3Haptic) {
                        withAnimation {
                            shadowProgress = 8.0
                            deleteProgress = 0.85
                        }
                        stage3Haptic.toggle()
                    }
                } else if (dragValue.translation.height >= 110.0) {
                    if (!stage2Haptic) {
                        withAnimation {
                            shadowProgress = 6.0
                            deleteProgress = 0.62
                        }
                        stage2Haptic.toggle()
                    }
                } else if (dragValue.translation.height >= 70.0) {
                    if (!stage1Haptic) {
                        withAnimation {
                            shadowProgress = 4.0
                            deleteIsShown = true
                            deleteProgress = 0.37
                        }
                        stage1Haptic.toggle()
                    }
                }
            }
            .onEnded { _ in
                if (stage3Haptic) {
                    dataManager.deletePhotoClip(photoURL: photoFileName)
                    
                    hasDeleted = true
                    
                    withAnimation {
                        initialOpacity = 0.0
                    }
                    
                    dismissKeyboard()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        dismissKeyboard()
                        deleteHaptic.toggle()
                        
                        withAnimation {
                            viewsIconHidden = false
                            offset = 500 * 2
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation {
                                    saveIsShown = false
                                }
                            }
                        }
                    }
                } else {
                    withAnimation {
                        stage1Haptic = false
                        stage2Haptic = false
                        stage3Haptic = false
                    }
                }
                
                withAnimation {
                    shadowProgress = 0.0
                    deleteIsShown = false
                }
            }
    }
    
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    if (deleteIsShown) {
                        TrashProgessView(progress: $deleteProgress)
                    }
                    
                    ZStack {
                        PhotoPreviewCard(photoFileName: $photoFileName, photoNote: $photoNote)
                    }
                    .padding([.bottom], 15)
                    .shadow(color: .red.opacity(0.3), radius: shadowProgress)
                    
                    VStack {
                        Button() {
                            dataManager.savePhotoClip(photoURL: photoFileName, note: photoNote, date: photoDate, modelContext: modelContext)
                            
                            hasSaved = true
                            
                            withAnimation {
                                initialOpacity = 0.0
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                dismissKeyboard()
                                saveHaptic.toggle()
                                
                                withAnimation {
                                    viewsIconHidden = false
                                    offset = geometry.size.height * 2
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        withAnimation {
                                            saveIsShown = false
                                        }
                                    }
                                }
                            }
                        } label: {
                            ZStack {
                                Image(colorScheme == .dark ? "GrainyBackgroundLight" : "GrainyBackground")
                                    .resizable()
                                    .scaledToFill()
                                Text("Save")
                                    .padding([.top, .bottom], 15)
                                    .foregroundStyle(colorScheme == .dark ? .black : .white)
                                    .font(Font.system(.title2))
                            }
                            .opacity(initialOpacity)
                            .frame(width: geometry.size.width - 80, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .frame(maxWidth: 500.0)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .simultaneousGesture(savePress)
                        .sensoryFeedback(.impact(weight: .medium), trigger: saveHaptic)
                        .sensoryFeedback(.impact(weight: .heavy), trigger: deleteHaptic)
                        .shadow(color: colorScheme == .dark ? .black : .white, radius: 0, x: 0, y: !tapHaptic ? 5 : 0)
                    }
                    .sensoryFeedback(.impact, trigger: tapHaptic)
                    .padding([.leading, .trailing])
                }
                .keyboardAutoPadding(offset: 35.0)
            }
            .simultaneousGesture(deleteGesture)
            .sensoryFeedback(.impact(flexibility: .soft), trigger: stage1Haptic)
            .sensoryFeedback(.impact(flexibility: .solid), trigger: stage2Haptic)
            .sensoryFeedback(.impact(flexibility: .rigid), trigger: stage3Haptic)
            .offset(y: CGFloat(offset))
            .onAppear {
                offset = geometry.size.height * 2
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation {
                        offset = 0
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation {
                            initialOpacity = 1.0
                        }
                    }
                }
            }
            .onDisappear {
                if (!(!hasSaved && hasDeleted) && !(hasSaved && !hasDeleted)) {
                    print("EXITED BEFORE, Deleting...")
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

#Preview {
    PhotoSaveView(photoFileName: .constant(""), saveIsShown: .constant(true), viewsIconHidden: .constant(true))
}
