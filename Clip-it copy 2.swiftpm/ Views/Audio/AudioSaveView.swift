//
//  SwiftUIView.swift
//  
//
//  Created by Diego Gutierrez on 26/01/24.
//

import SwiftUI
import TipKit

struct PreviewToolTip: Tip {
    var title: Text {
        Text("Preview")
    }

    var message: Text? {
        Text("Press and hold to preview the audio")
    }

    var asset: Image? {
        Image(systemName: "music.note")
    }
}

struct DeleteToolTip: Tip {
    var title: Text {
        Text("Delete")
    }

    var message: Text? {
        Text("Swipe down to delete")
    }

    var asset: Image? {
        Image(systemName: "hand.draw")
    }
}

struct AudioSaveView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var audioRecorder: AudioRecorder
    @Binding var completedRecording: Bool
    @Binding var viewsIconHidden: Bool
    @State var recordingURL: String
    @Binding var isShown: Bool
    @State var offset = 500.0
    @State var recordingNote:String = ""
    @State var recordingDate = Date()
    
    @State var waveformPercentage = 0.0
    @State var animationsRunning = false
    @State var initialOpacity = 0.0
    
    @State var saveHaptic = false
    @State var deleteHaptic = false
    @State var tapHaptic = false
    
    @State var playbackIsRunning = false
    
    @State var hasDeleted = false
    @State var hasSaved = false
    
    @FocusState var areaIsFocused: Bool
    
    @State var deleteProgress = 0.0
    @State var shadowProgress = 0.0
    @State var deleteIsShown = false
    @State var stage1Haptic = false
    @State var stage2Haptic = false
    @State var stage3Haptic = false
    
    @State var previewIsShown = true
    
    var dataManager = DataManager()
    
    private let previewToolTip = PreviewToolTip()
    private let deleteToolTip = DeleteToolTip()
    
    var longPress: some Gesture {
        LongPressGesture(minimumDuration: 0.5)
            .onEnded { _ in
                previewToolTip.invalidate(reason: .actionPerformed)
                previewIsShown = false
                
                audioRecorder.startPreview(recordingURL: recordingURL, waveformPercentage: $waveformPercentage, animationsRunning: $animationsRunning, playbackIsRunning: $playbackIsRunning)
                
                withAnimation {
                    playbackIsRunning = true
                    animationsRunning = true
                }
            }
    }
    
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
                        deleteToolTip.invalidate(reason: .actionPerformed)
                        
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
                    dataManager.deleteAudio(recordingURL: recordingURL)
                    
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
                                    completedRecording = false
                                    isShown = true
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
                    if (!previewIsShown) {
                        TipView(deleteToolTip, arrowEdge: .bottom)
                            .padding([.leading, .trailing])
                    }
                    
                    if (deleteIsShown) {
                        TrashProgessView(progress: $deleteProgress)
                    }
                    
                    ZStack {
                        if (playbackIsRunning) {
                            FloatingIcons(width: geometry.size.width)
                        }
                        
                        ZStack {
                            Rectangle()
                                .fill(.white)
                            TextField("Write a note...", text: $recordingNote, prompt: Text("Write a note...").foregroundStyle(.gray), axis: .vertical)
                                .foregroundStyle(.black)
                                .font(Font.system(.title2))
                                .padding()
                                .focused($areaIsFocused)
                                .onTapGesture {
                                    areaIsFocused = true
                                }
                                .frame(maxWidth: 500.0)
                        }
                        .frame(width: geometry.size.width - 50, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .frame(maxWidth: 500.0)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding([.bottom], 15)
                    .shadow(color: .red.opacity(0.5), radius: shadowProgress)
                    
                    VStack {                        
                        Button() {
                            dataManager.saveAudioSession(recordingURL: recordingURL, note: recordingNote, date: recordingDate, modelContext: modelContext)
                            
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
                                            completedRecording = false
                                            isShown = true
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
                            .frame(width: geometry.size.width - 50, height: 60)
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
                .keyboardAutoPadding(offset: 50.0)
                
                Button() {
                    if (playbackIsRunning) {
                        audioRecorder.stopPreview()
                    }
                } label: {
                    Image(systemName: "waveform", variableValue: waveformPercentage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                        .tint(colorScheme == .dark ? .white : .black)
                        .symbolEffect(.variableColor.reversing.cumulative, options: .repeat(1).speed(0.2), value: animationsRunning)
                        .popoverTip(previewToolTip, arrowEdge: .bottom)
                }
                .ignoresSafeArea(.keyboard)
                .opacity(initialOpacity)
                .position(CGPoint(x: geometry.size.width / 2, y: geometry.size.height - 20))
                .simultaneousGesture(longPress)
                .sensoryFeedback(.increase, trigger: animationsRunning)
            }
            .simultaneousGesture(deleteGesture)
            .sensoryFeedback(.impact(flexibility: .soft), trigger: stage1Haptic)
            .sensoryFeedback(.impact(flexibility: .solid), trigger: stage2Haptic)
            .sensoryFeedback(.impact(flexibility: .rigid), trigger: stage3Haptic)
            .offset(y: CGFloat(offset))
            .onAppear {
                withAnimation {
                    isShown = false
                }
                
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
                    print("EXITED BEFORE DELETING")
//                    dataManager.deleteAudio(recordingURL: recordingURL)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

#Preview {
    AudioSaveView(completedRecording: .constant(false), viewsIconHidden: .constant(true), recordingURL: "", isShown: .constant(true))
}
