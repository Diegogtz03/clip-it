import SwiftUI
import SwiftData

@Model
class AudioRecording {
    @Attribute(.unique) var id: UUID
    var date: Date
    var note: String
    var url: String
    
    init(id: UUID, date: Date, note: String, url: String) {
        self.id = id
        self.date = date
        self.note = note
        self.url = url
    }
}


@Model
class PhotoClip {
    @Attribute(.unique) var id: UUID
    var date: Date
    var note: String
    var url: String
    
    init(id: UUID, date: Date, note: String, url: String) {
        self.id = id
        self.date = date
        self.note = note
        self.url = url
    }
}
