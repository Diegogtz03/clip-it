//
//  SwiftUIView.swift
//  
//
//  Created by Diego Gutierrez on 05/02/24.
//

import SwiftUI

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

struct AudioHistory: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var audioRecorder: AudioRecorder
    
    @Environment(\.dismiss) var dismiss
    
    @State var audioSession: AudioRecording
    @State var isPlaying = false
    @State var isInitialPlay = true
    
    @State var progressWidth = 0.0
    @State var maxWidth = 50.0
    @State var isChangingProgress = false
    
    @State var deleteHaptic = false
    @State var playPauseHaptic = false
    
    var dataManager = DataManager()
    
    func translateTimeToWidth() {
        withAnimation {
            progressWidth = (maxWidth / audioRecorder.completeTime) * audioRecorder.playingTime
        }
    }
    
    func translateWidthToTime() -> TimeInterval {
        return (progressWidth) / (maxWidth / audioRecorder.completeTime)
    }
    
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
    
    func getAudioURL(audioURL: String) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent(audioURL)
    }
    
    var progressGesture: some Gesture {
        DragGesture(minimumDistance: 0.0)
            .onChanged { dragValue in
                withAnimation {
                    if (dragValue.location.x <= maxWidth) {
                        progressWidth = dragValue.location.x
                    }
                    
                    isChangingProgress = true
                }
            }
            .onEnded { _ in
                if (isInitialPlay) {
                    let _ = audioRecorder.getTrackTime(recordingURL: audioSession.url)
                    audioRecorder.changeInitialPlayingTime(givenTime: translateWidthToTime())
                } else {
                    audioRecorder.changeCurrentPlayingTime(givenTime: translateWidthToTime())
                }
                
                withAnimation {
                    isChangingProgress = false
                }
            }
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
                    if (isPlaying) {
                        withAnimation {
                            isPlaying = false
                        }
                        
                        audioRecorder.stopAudio()
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
                    
                        Text(formatDateKey(date:audioSession.date))
                            .bold()
                            .font(Font.system(.largeTitle))
                            .foregroundStyle(.gray)
                        
                        Spacer()
                    }
                    
                    Spacer()
                                        
                    Text(audioSession.note)
                        .font(Font.system(.title2))
                        .bold()
                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                        .padding([.bottom], 25)
                    
                    ZStack {
                        if (isPlaying) {
                            FloatingIcons(width: geometry.size.width)
                        }
                        
                        Cassette(isRecording: $isPlaying)
                            .shadow(color: .black, radius: 0.2)
                    }
                    
                    Spacer()
                    
                    VStack {
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(.gray)
                                .mask(Capsule())
                            
                            Capsule()
                                .fill(.white)
                                .frame(width: progressWidth)
                        }
                        .gesture(progressGesture)
                        .frame(height: !isChangingProgress ? 10 : 20)
                        .padding([.bottom], 15)
                        .padding([.leading, .trailing], 35)
                        .onAppear {
                            maxWidth = geometry.size.width - (35 * 2)
                        }
                        .onChange(of: audioRecorder.playingTime) { oldValue, newValue in
                            if (!isChangingProgress) {
                                translateTimeToWidth()
                            }
                        }
                        
                        HStack(alignment: .center) {
                            Button() {
                                dataManager.deleteComboAudioSession(recordingURL: audioSession.url, audioSession: audioSession, modelContext: modelContext)
                                
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
                            
                            Button() {
                                if (!isPlaying && isInitialPlay) {
                                    audioRecorder.startAudio(recordingURL: audioSession.url, isPlaying: $isPlaying, isInitialPlay: $isInitialPlay)
                                    isInitialPlay = false
                                } else {
                                    audioRecorder.toggleAudio(isPlaying: isPlaying)
                                }
                                
                                playPauseHaptic.toggle()
                                
                                withAnimation {
                                    isPlaying.toggle()
                                }
                                
                            } label: {
                                Image(systemName: !isPlaying ? "play.fill" : "pause.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                    .frame(width: 30)
                            }
                            .contentTransition(.symbolEffect(.replace))
                            .sensoryFeedback(.impact(flexibility: .soft), trigger: playPauseHaptic)
                            
                            Spacer()
                            
                            ShareLink(item: getAudioURL(audioURL: audioSession.url), subject: Text("Clip-it Audio"), label: {
                                Image(systemName: "square.and.arrow.up")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(.blue)
                                    .frame(width: 25)
                            })
                        }
                        .padding(10)
                        .padding([.leading, .trailing], 35)
                    }
                    .padding([.bottom], 25)
                }
                .navigationBarBackButtonHidden()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onDisappear {
                if (isPlaying) {
                    audioRecorder.stopAudio()
                }
            }
        }
    }
}

#Preview {
    AudioHistory(audioSession: .init(id: UUID(), date: Date(), note: "", url: ""))
}
