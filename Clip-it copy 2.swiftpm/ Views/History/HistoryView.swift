//
//  SwiftUIView.swift
//  
//
//  Created by Diego Gutierrez on 04/02/24.
//

import SwiftUI
import SwiftData

enum Clip: Hashable {
    case audio(AudioRecording)
    case photo(PhotoClip)
}

enum Filter: String, CaseIterable, Identifiable {
    case all, audios, photos
    var id: Self { self }
}

struct HistoryView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext
    @StateObject var audioRecorder = AudioRecorder()
    @Binding var opacityAnimation: Bool
    @Query var audios: [AudioRecording]
    @Query var photos: [PhotoClip]
    
    @State var opacity = 0.0
    @State var searchText = ""
    @State var selectedFilter: Filter = .all
    @FocusState var searchIsFocused: Bool
    
    @State var groupedClips: [Date: [Clip]] = [:]
    
    func groupClips() -> [Date: [Clip]] {
        var result: [Date: [Clip]] = [:]
        
        let allClips = audios.map { Clip.audio($0) } + photos.map { Clip.photo($0) }
        
        allClips.forEach { clip in
            var date: Date
            switch clip {
            case .audio(let audio):
                date = audio.date
            case .photo(let photo):
                date = photo.date
            }
    
            let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
            let finalDate = Calendar.current.date(from: components)!
            let existing = result[finalDate] ?? []
            result[finalDate] = [clip] + existing
        }
        
        return result
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
    
    var filteredClips: [Date: [Clip]] {
        return groupedClips.compactMapValues { clipsForDate in
            clipsForDate.filter { clip in
                if (selectedFilter != .all) {
                    switch clip {
                    case .audio(let audio):
                        if !searchText.isEmpty && selectedFilter == .audios {
                            return audio.note.lowercased().contains(searchText.lowercased())
                        } else if (selectedFilter == .audios) {
                            return true
                        }
                        
                        return false
                    case .photo(let photo):
                        if !searchText.isEmpty && selectedFilter == .photos {
                            return photo.note.lowercased().contains(searchText.lowercased())
                        } else if (selectedFilter == .photos) {
                            return true
                        }
                        
                        return false
                    }
                } else {
                    if (!searchText.isEmpty) {
                        switch clip {
                        case .audio(let audio):
                            return audio.note.lowercased().contains(searchText.lowercased())
                        case .photo(let photo):
                            return photo.note.lowercased().contains(searchText.lowercased())
                        }
                    } else {
                        return true
                    }
                }
            }
        }
    }
    
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
     
    var body: some View {
        VStack {
            ScrollView {
                ForEach(filteredClips.sorted(by: { $0.key > $1.key }), id: \.key) { date, clips in
                    if (clips.count != 0) {
                        Section {
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(clips, id: \.self) { clip in
                                        switch clip {
                                        case .audio(let audio):
                                            NavigationLink {
                                                AudioHistory(audioSession: audio)
                                                    .environment(\.modelContext, modelContext)
                                                    .environmentObject(audioRecorder)
                                            } label: {
                                                AudioHistoryItem(audio: audio)
                                            }
                                        case .photo(let photo):
                                            NavigationLink {
                                                PhotoHistory(photoClip: photo)
                                                    .environment(\.modelContext, modelContext)
                                            } label: {
                                                PhotoHistoryItem(photoClip: photo)
                                            }
                                        }
                                    }
                                }
                            }
                            .mask(LinearGradient(gradient: Gradient(stops: [
                                .init(color: .clear, location: 0),
                                .init(color: .black, location: 0.05),
                                .init(color: .black, location: 0.9),
                                .init(color: .clear, location: 1)
                            ]), startPoint: .leading, endPoint: .trailing))
                            .scrollIndicators(.hidden)
                            .onTapGesture {
                                if (searchIsFocused) {
                                    dismissKeyboard()
                                }
                            }
//                            .simultaneousGesture(DragGesture().onChanged({_ in 
//                                if (searchIsFocused) {
//                                    dismissKeyboard()
//                                }
//                            }))
                        } header: {
                            HStack {
                                Text(formatDateKey(date: date))
                                    .font(Font.system(.title3))
                                    .foregroundStyle(.gray)
                                    .bold()
                                
                                Spacer()
                            }
                        }
                    }
                }
            }
            .mask(LinearGradient(gradient: Gradient(stops: [
                .init(color: .clear, location: 0),
                .init(color: .black, location: 0.01),
                .init(color: .black, location: 0.95),
                .init(color: .clear, location: 1)
            ]), startPoint: .top, endPoint: .bottom))
            .scrollIndicators(.hidden)
            .padding([.top], 5)
            .onTapGesture {
                if (searchIsFocused) {
                    dismissKeyboard()
                }
            }
//            .simultaneousGesture(DragGesture().onChanged({ _ in
//                if (searchIsFocused) {
//                    dismissKeyboard()
//                }
//            }))
            
            Spacer()
            
            HStack(spacing: 10.0) {
                ZStack {
                    Image(colorScheme == .dark ? "GrainyBackgroundLight" : "GrainyBackground")
                        .resizable()
                        .scaledToFill()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .frame(height: 50)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .opacity(0.7)
                        .allowsHitTesting(false)
                    TextField("Search", text: $searchText, prompt: Text("Search").foregroundStyle(.gray))
                        .padding(8)
                        .padding([.leading, .trailing], 12)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .focused($searchIsFocused)
                        .foregroundStyle(colorScheme == .dark ? .black : .white)
                }
                .frame(height: 50)
                .overlay {
                    if !searchText.isEmpty {
                        HStack {
                            Spacer()
                            
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "multiply.circle.fill")
                            }
                            .foregroundColor(colorScheme == .dark ? .gray : .white)
                            .padding(.trailing, 10)
                        }
                    }
                }
                
                Menu {
                    Picker("", selection: $selectedFilter) {
                        Text("📸 Photos").tag(Filter.photos)
                        Text("🎶 Audios").tag(Filter.audios)
                        Text("All").tag(Filter.all)
                    }
                    .labelsHidden()
                } label: {
                    Image(systemName: selectedFilter == .all ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundStyle(colorScheme == .dark ? .white : .gray)
                }
            }
            .frame(height: 50)
            .keyboardAutoPadding(offset: 35.0)
            .padding([.bottom], 15)
            .padding([.trailing], 15)
            .frame(maxWidth: 500.0)
        }
        .opacity(opacity)
        .padding([.top], 30)
        .padding([.leading], 15)
        .onAppear {
            self.groupedClips = groupClips()
            withAnimation {
                opacity = 1.0
            }
        }
        .onChange(of: opacityAnimation) { _, newValue in
            if(newValue) {
                withAnimation {
                    opacity = 0.0
                }
            }
        }
    }
}

#Preview {
    HistoryView(opacityAnimation: .constant(true))
}
