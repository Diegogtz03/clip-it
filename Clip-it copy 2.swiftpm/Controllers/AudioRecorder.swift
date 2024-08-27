//
//  File.swift
//  
//
//  Created by Diego Gutierrez on 26/01/24.
//

import Foundation
import AVFoundation
import SwiftUI

class AudioRecorder: NSObject, ObservableObject, AVAudioPlayerDelegate {
    @Published var recordingSamples:[Float] = []
    @Published var playingTime = 0.0
    @Published var completeTime = 0.0
    
    var audioRecorder: AVAudioRecorder!
    var recordingSession: AVAudioSession = AVAudioSession.sharedInstance()
    var isRecordingSamples = false
    
    var waveformPercentage: Binding<Double>?
    var animationsRunning: Binding<Bool>?
    var playbackIsRunning: Binding<Bool>?
    
    var isPlaying: Binding<Bool>?
    var isInitialPlay: Binding<Bool>?
    var isInHistory = false
    
    var hasChangedInterval = false
    
    private let timeoutSeconds = 1
    private var timer : DispatchSourceTimer?
    
    var audioPlayer: AVAudioPlayer?
    
    override init() {
        super.init()
    }
    
    func checkPermissions() async {
        if await AVAudioApplication.requestRecordPermission() {
            // Continue
            print("Access Granted")
        } else {
            // TODO: Show settings (warning) (block gesture)
            print("No access to audio recording")
        }
    }
    
    func configureAudioSession() {
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Something went wrong")
        }
    }
    
    func startRecording() -> String {
        configureAudioSession()
        recordingSamples = []
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let fileName = UUID().uuidString + ".m4a"
            let finalFileName = paths[0].appendingPathComponent(fileName)
            
            
            audioRecorder = try AVAudioRecorder(url: finalFileName, settings: settings)
            audioRecorder.isMeteringEnabled = true
            audioRecorder.record()
            
            isRecordingSamples = true
            
            startRecordingSamples()
            
            return fileName
        } catch {
            stopRecording()
        }
        
        return ""
    }
    
    func stopRecording() {
        stopRecordingSamples()
        audioRecorder.stop()
        audioRecorder = nil
    }
    
    func startPreview(recordingURL: String, waveformPercentage: Binding<Double>, animationsRunning: Binding<Bool>, playbackIsRunning: Binding<Bool>) {
        self.waveformPercentage = waveformPercentage
        self.animationsRunning = animationsRunning
        self.playbackIsRunning = playbackIsRunning
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            let finalURL = checkFileName(fileName: recordingURL)
            let data = try Data(contentsOf: finalURL)
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.play()
        } catch {
            print("Error loading audio file: \(error)")
        }
    }
    
    func stopPreview() {
        withAnimation {
            waveformPercentage?.wrappedValue = 0.0
            animationsRunning?.wrappedValue = false
            playbackIsRunning?.wrappedValue = false
        }
        
        let fadeDelay = 0.8
        audioPlayer?.setVolume(0.0, fadeDuration: fadeDelay)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + fadeDelay) {
            self.audioPlayer?.stop()
            self.audioPlayer = nil
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if (!isInHistory) {
            DispatchQueue.main.async {
                withAnimation {
                    self.waveformPercentage?.wrappedValue = 0.0
                    self.animationsRunning?.wrappedValue = false
                    self.playbackIsRunning?.wrappedValue = false
                }
                
                let fadeDelay = 0.8
                self.audioPlayer?.setVolume(0.0, fadeDuration: fadeDelay)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + fadeDelay) {
                    self.audioPlayer?.stop()
                    self.audioPlayer = nil
                }
            }
        } else {
            DispatchQueue.main.async {
                self.stopAudio()
            }
        }
    }
    
    func startAudio(recordingURL: String, isPlaying: Binding<Bool>, isInitialPlay: Binding<Bool>) {
        self.isPlaying = isPlaying
        self.isInitialPlay = isInitialPlay
        self.isInHistory = true
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            let finalPath = checkFileName(fileName: recordingURL)
            
            let data = try Data(contentsOf: finalPath)
            audioPlayer = try AVAudioPlayer(data: data)
            completeTime = audioPlayer?.duration ?? 0.0
            audioPlayer?.delegate = self
            if (!hasChangedInterval) {
                audioPlayer?.play()
            } else {
                audioPlayer?.currentTime = playingTime
                audioPlayer?.play()
            }
            
            startTimeSamples()
        } catch {
            print("Error loading audio file: \(error)")
        }
    }
    
    func getTrackTime(recordingURL: String) -> TimeInterval {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            let finalPath = checkFileName(fileName: recordingURL)
            
            let data = try Data(contentsOf: finalPath)
            audioPlayer = try AVAudioPlayer(data: data)
            completeTime = audioPlayer?.duration ?? 0.0
            
            self.audioPlayer = nil
            
            return completeTime
        } catch {
            print("Error loading audio file: \(error)")
        }
        
        return 0.0
    }
    
    func toggleAudio(isPlaying: Bool) {
        if (isPlaying) {
            audioPlayer?.pause()
            timer!.suspend()
        } else {
            audioPlayer?.play()
            timer!.resume()
            
            hasChangedInterval = false
        }
    }
    
    func stopAudio() {
        withAnimation {
            isPlaying?.wrappedValue = false
            playingTime = 0.0
        }
        
        self.audioPlayer?.stop()
        self.audioPlayer = nil
        
        isInHistory = false
        isInitialPlay?.wrappedValue = true
        
        stopTimeSamples()
        hasChangedInterval = false
        completeTime = 0.0
    }
    
    func changeCurrentPlayingTime(givenTime: TimeInterval) {
        timer?.suspend()
        audioPlayer?.currentTime = givenTime
        timer?.resume()
    }
    
    func changeInitialPlayingTime(givenTime: TimeInterval) {
        playingTime = givenTime
        hasChangedInterval = true
    }
    
    func checkFileName(fileName: String) -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        if (fileName.contains("/")) {
            return paths[0].appendingPathComponent(URL(string: fileName)?.lastPathComponent ?? "")
        }
        
        return paths[0].appendingPathComponent(fileName)
    }
    
    func startRecordingSamples() {
        let interval : DispatchTimeInterval = .milliseconds(20)
        
        if timer == nil {
            timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
            timer!.schedule(deadline: .now() + .seconds(timeoutSeconds), repeating: interval)
            timer!.setEventHandler {
                self.audioRecorder.updateMeters()
                var sample = 1 - pow(10, self.audioRecorder.averagePower(forChannel: 0) / 20)

                // Normalize samples (avoid huge samples) 0.7 - 0.8 MIN (MAX)
                // (HIGH) 0.7 -> 1.5 (LOW) --> TOP IT OFF AT
                
                if (sample < 0.6) {
                    sample = 0.6
                }
                
                DispatchQueue.main.async {
                    self.recordingSamples += [sample, sample, sample, sample, sample]
                }
            }
            timer!.resume()
        }
    }
    
    func stopRecordingSamples() {
        timer?.cancel()
        timer = nil
    }
    
    func startTimeSamples() {
        let interval : DispatchTimeInterval = .milliseconds(50)
        
        stopTimeSamples()
        
        timer = DispatchSource.makeTimerSource(queue: DispatchQueue.global())
        timer!.schedule(deadline: .now() + .seconds(timeoutSeconds), repeating: interval)
        timer!.setEventHandler {
            DispatchQueue.main.async {
                self.playingTime = self.audioPlayer?.currentTime ?? self.playingTime + 1.0
            }
        }
        timer!.resume()
    }
    
    func stopTimeSamples() {
        if (timer != nil) {
            timer?.cancel()
        }
    }
}
