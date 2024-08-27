import SwiftUI

struct LaunchScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @State var launchIsActive: Bool = true
    @State var launchAnimation: Namespace.ID
    
    var body: some View {
        ZStack {
            Image(colorScheme == .dark ? "GrainyBackground" : "GrainyBackgroundLight")
                .resizable()
                .ignoresSafeArea()
                .scaledToFill()
            
            Image(colorScheme == .dark ? "ClipItLogo" : "ClipItLogoLight")
                .resizable()
                .scaledToFit()
                .frame(width: launchIsActive ? 130 : 35)
                .matchedGeometryEffect(id: "logo", in: launchAnimation)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                withAnimation {
                    self.launchIsActive.toggle()
                }
            }
        }
    }
}
