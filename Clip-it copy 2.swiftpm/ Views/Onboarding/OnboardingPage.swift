//
//  SwiftUIView.swift
//  
//
//  Created by Diego Gutierrez on 10/02/24.
//

import SwiftUI

struct OnboardingPage: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @State var launchAnimation: Namespace.ID
    
    @Binding var onboardingIsActive: Bool
    
    @State var tapHaptic = false
    
    @State var pageVideo: PageVideo = .page1
    @State var pageText: PageText = .page1
    
    @State var opacity = 1.0
    
    var btnGesture: some Gesture {
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
    
    enum PageVideo: String {
        case page1 = "Onboarding01"
        case page2 = "Onboarding02"
        case page3 = "Onboarding03"
    }
    
    enum PageText: String {
        case page1 = "To access different modes, simply swipe! Keep the icons pressed to activate the feature!"
        case page2 = "Once done, write a note and save! Or if you change your mind, simply swipe down to delete."
        case page3 = "You can access and manage your clip-it’s on the top right corner. Click it again to go back."
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
                
                VStack {
                    Image(colorScheme == .dark ? "ClipItLogo" : "ClipItLogoLight")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35)
                        .matchedGeometryEffect(id: "logo", in: launchAnimation)
                        .padding([.top], 15)
                    
                    Spacer()
                    
                    ZStack {
                        Rectangle()
                            .fill(colorScheme == .dark ? Color(red: 0.85, green: 0.85, blue: 0.85) : Color(red: 0.59, green: 0.59, blue: 0.59))
                        
                        Image(pageVideo.rawValue)
                            .resizable()
                            .scaledToFit()
                    }
                    .frame(width: geometry.size.width / 1.3, height: geometry.size.height / 2)
                    .clipShape(RoundedRectangle(cornerRadius: 10.0))
                    .frame(maxWidth: 500.0)
                    .clipShape(RoundedRectangle(cornerRadius: 10.0))
                    .opacity(opacity)
                    
                    Spacer()
                    
                    Text(pageText.rawValue)
                        .foregroundStyle(colorScheme == .dark ? .gray : .black)
                        .font(Font.custom("Inter-Thin", size: (verticalSizeClass == .regular && horizontalSizeClass == .regular) ? 28 : 22))
                        .fontWeight(.thin)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .padding([.top, .bottom], 15)
                        .padding([.leading, .trailing], 30)
                        .opacity(opacity)
                    
                    Spacer()
                    
                    Button() {
                        if (pageText != .page3) {
                            withAnimation {
                                if (pageText == .page1) {
                                    pageText = .page2
                                    pageVideo = .page2
                                } else if (pageText == .page2) {
                                    pageText = .page3
                                    pageVideo = .page3
                                }
                            }
                        } else {
                            let defaults = UserDefaults.standard
                            
                            defaults.set(true, forKey: "notFirstLaunch")
                            
                            withAnimation {
                                opacity = 0.0
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    onboardingIsActive = false
                                }
                            }
                        }
                    } label: {
                        ZStack {
                            Image(colorScheme == .dark ? "GrainyBackgroundLight" : "GrainyBackground")
                                .resizable()
                                .scaledToFill()
                            Text(pageText != .page3 ? "Next" : "Get clippin’")
                                .padding([.top, .bottom], 15)
                                .foregroundStyle(colorScheme == .dark ? .black : .white)
                                .font(Font.system(.title2))
                        }
                        .frame(width: geometry.size.width - 50, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(maxWidth: 500.0)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .simultaneousGesture(btnGesture)
                    .shadow(color: colorScheme == .dark ? .black : .white, radius: 0, x: 0, y: !tapHaptic ? 5 : 0)
                    .padding([.bottom], 30)
                    .opacity(opacity)
                }
            }
            .sensoryFeedback(.impact, trigger: tapHaptic)
            .navigationBarBackButtonHidden()
        }
    }
}

#Preview {
    OnboardingPage(launchAnimation: Namespace().wrappedValue, onboardingIsActive: .constant(true))
}
