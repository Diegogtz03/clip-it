//
//  SwiftUIView.swift
//  
//
//  Created by Diego Gutierrez on 26/01/24.
//

import SwiftUI
import DSWaveformImage
import DSWaveformImageViews
import TipKit

struct PressAndHoldTip: Tip {
    var asset: Image? {
        Image(systemName: "waveform")
    }
    
    var title: Text {
        Text("Record")
    }

    var message: Text? {
        Text("Press and hold to start recording")
    }
}

struct AudioView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    
    @Binding var offsetAnimation: Bool
    @Binding var viewsIconHidden: Bool
    @StateObject var audioRecorder = AudioRecorder()
    @State var isRecording = false
    @State var completedRecording = false
    @State var longPressDetected = false
    @State var isClicked = false
    
    @State var isShown = false
    
    @State var recordingURL = ""
    @State var opacityValue = 0.0
    
    @State private var liveConfiguration: Waveform.Configuration = Waveform.Configuration(
        style: .striped(.init(color: .gray, width: 10, spacing: 5))
    )
    
    private let pressAndHoldTip = PressAndHoldTip()
    
    var longPress: some Gesture {
        LongPressGesture(minimumDuration: 0.4)
            .onEnded { _ in
                if (!completedRecording) {
                    withAnimation {
                        isClicked = true
                        longPressDetected = true
                    }
                    
                    pressAndHoldTip.invalidate(reason: .actionPerformed)
                    
                    audioRecorder.recordingSamples = []
                    
                    withAnimation {
                        isRecording = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        recordingURL = audioRecorder.startRecording()
                    }
                }
            }
    }
    
    var body: some View {
        GeometryReader { geometry in
            if (isRecording) {
                WaveformLiveCanvas(
                    samples: audioRecorder.recordingSamples,
                    configuration: liveConfiguration,
                    renderer: LinearWaveformRenderer(),
                    shouldDrawSilencePadding: true
                )
                .opacity(opacityValue)
                .padding([.leading, .trailing], 5)
                .mask(LinearGradient(gradient: Gradient(stops: [
                    .init(color: .clear, location: 0),
                    .init(color: .black, location: 0.20),
                    .init(color: .black, location: 0.85),
                    .init(color: .clear, location: 1)
                ]), startPoint: .leading, endPoint: .trailing))
                .offset(y: -70)
                .onAppear {
                    withAnimation {
                        opacityValue = 1.0
                    }
                }
            } else {
                if (completedRecording) {
                    AudioSaveView(completedRecording: $completedRecording, viewsIconHidden: $viewsIconHidden, recordingURL: recordingURL, isShown: $isShown)
                        .environment(\.modelContext, modelContext)
                        .environmentObject(audioRecorder)
                        .ignoresSafeArea(.keyboard)
                        .onAppear {
                            withAnimation {
                                viewsIconHidden = true
                            }
                        }
                }
            }
            
            Button() {
                if self.longPressDetected {
                    withAnimation {
                        isClicked = false
                        longPressDetected = false
                        isRecording = false
                        completedRecording = true
                    }
                    
                    audioRecorder.stopRecording()
                }
            } label: {
                Cassette(isRecording: $isRecording)
                    .ignoresSafeArea(.keyboard)
                    .scaleEffect((verticalSizeClass == .regular && horizontalSizeClass == .regular) ? (!isRecording ? 1.20 : 1.15) : (!isRecording ? 0.8 : 0.75))
                    .popoverTip(pressAndHoldTip, arrowEdge: .bottom)
            }
            .ignoresSafeArea(.keyboard)
            .sensoryFeedback(.impact(flexibility: .solid, intensity: 1), trigger: isRecording)
            .simultaneousGesture(longPress)
            .buttonStyle(PlainButtonStyle())
            .frame(width: geometry.size.width)
            .offset(y: isShown ? geometry.size.height - 115 : (verticalSizeClass == .regular && horizontalSizeClass == .regular) ? geometry.size.height + 50 : geometry.size.height + 30)
            .task {
                await audioRecorder.checkPermissions()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation {
                        if (!completedRecording) {
                            isShown = true
                        }
                    }
                }
            }
            .onDisappear {
                withAnimation {
                    isShown = false
                }
            }
            .onChange(of: offsetAnimation, { oldValue, newValue in
                if (newValue) {
                    withAnimation {
                        isShown = false
                    }
                }
            })
        }
    }
}

#Preview {
    AudioView(offsetAnimation: .constant(false), viewsIconHidden: .constant(true))
}
