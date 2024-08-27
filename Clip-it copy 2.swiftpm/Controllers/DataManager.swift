//
//  File.swift
//  
//
//  Created by Diego Gutierrez on 27/01/24.
//

import Foundation
import SwiftData
import AVFoundation

class DataManager {
    // AUDIO DATA
    func saveAudioSession(recordingURL: String, note: String, date: Date, modelContext: ModelContext) {
        let newSession = AudioRecording(id: UUID(), date: date, note: note, url: recordingURL)
        modelContext.insert(newSession)
    }
    
    func deleteAudio(recordingURL: String) {
        do {
            let fileManager = FileManager.default
            let fileURL = checkFileName(fileName: recordingURL)
            
            try fileManager.removeItem(at: fileURL)
            print("File successfully deleted.")
        } catch {
            print("Error deleting file: \(error)")
        }
    }
    
    func deleteComboAudioSession(recordingURL: String, audioSession: AudioRecording, modelContext: ModelContext) {
        deleteAudio(recordingURL: recordingURL)
        modelContext.delete(audioSession)
    }
    
    
    // PHOTO DATA
    func savePhotoClip(photoURL: String, note: String, date: Date, modelContext: ModelContext) {
        let newPhotoClip = PhotoClip(id: UUID(), date: date, note: note, url: photoURL)
        modelContext.insert(newPhotoClip)
    }
    
    func deletePhotoClip(photoURL: String) {
        do {
            let fileManager = FileManager.default
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent(photoURL)
            try fileManager.removeItem(at: fileURL)
            print("File successfully deleted.")
        } catch {
            print("Error deleting file: \(error)")
        }
    }
    
    func deleteComboPhotoclip(photoURL: String, photoClip: PhotoClip, modelContext: ModelContext) {
        deletePhotoClip(photoURL: photoURL)
        modelContext.delete(photoClip)
    }
    
    func checkFileName(fileName: String) -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        if (fileName.contains("/")) {
            return paths[0].appendingPathComponent(URL(string: fileName)?.lastPathComponent ?? "")
        }
        
        return paths[0].appendingPathComponent(fileName)
    }
}
