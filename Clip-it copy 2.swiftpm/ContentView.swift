import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @State var launchIsActive: Bool = true;
    @State var onboardingIsActive: Bool = true;
    @Namespace var launchAnimation
    
    let defaults = UserDefaults.standard
    
    
    func loadSampleData() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        // Load audio 1 --> Sick Bassss
        if let audioURL = Bundle.main.url(forResource: "sickBass", withExtension: "mp3") {
            do {
                let audio1URL = paths[0].appendingPathComponent(audioURL.lastPathComponent)
                try FileManager.default.copyItem(at: audioURL, to: audio1URL)
            } catch {
                print("Failed converting audio")
                return
            }
        } else {
            print("Audio file not found.")
            return
        }
        
        let audio1 = AudioRecording(id: UUID(), date: Date(), note: "Sick Basss!! 🎶", url: "sickBass.mp3")
        modelContext.insert(audio1)
        
        
        // Load picture 1 --> Cat Food
        guard let uiImage = UIImage(named: "catFoodExample") else {
            print("Failed to load the example image")
            return
        }
        
        guard let imageData = uiImage.jpegData(compressionQuality: 0.9) else {
            print("Failed to convert the image to JPEG data")
            return
        }
        
        do {
            let picture1URL = paths[0].appendingPathComponent("CatFood.png")
            try imageData.write(to: picture1URL)
        } catch {
            print("Error saving the image: \(error)")
        }
        
        let picture1 = PhotoClip(id: UUID(), date: Date(), note: "Paw's food", url: "CatFood.png")
        modelContext.insert(picture1)
        
        
        // Load picture 2 --> popcorn
        guard let uiImage = UIImage(named: "popcornExample") else {
            print("Failed to load the example image")
            return
        }
        
        guard let imageData = uiImage.jpegData(compressionQuality: 0.9) else {
            print("Failed to convert the image to JPEG data")
            return
        }
        
        do {
            let picture2URL = paths[0].appendingPathComponent("popcorn.png")
            try imageData.write(to: picture2URL)
        } catch {
            print("Error saving the image: \(error)")
        }
        
        let picture2 = PhotoClip(id: UUID(), date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, note: "These were fire!", url: "popcorn.png")
        modelContext.insert(picture2)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if (launchIsActive) {
                    LaunchScreen(launchAnimation: launchAnimation)
                } else if (!launchIsActive && onboardingIsActive) {
                    InitialOnboarding(launchAnimation: launchAnimation, onboardingIsActive: $onboardingIsActive)
                } else {
                    MainView(launchAnimation: launchAnimation)
                        .environment(\.modelContext, modelContext)
                        .ignoresSafeArea(.keyboard)
                }
            }
        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            if defaults.bool(forKey: "notFirstLaunch") {
                onboardingIsActive = false
            } else {
                onboardingIsActive = true
                
                // ADD SAMPLE DATA (REMOVE FOR RELEASE)
                loadSampleData()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    self.launchIsActive.toggle()
                }
            }
        }
    }
}
