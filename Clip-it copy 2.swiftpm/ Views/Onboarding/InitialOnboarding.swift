//
//  SwiftUIView.swift
//  
//
//  Created by Diego Gutierrez on 10/02/24.
//

import SwiftUI

struct InitialOnboarding: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @State var launchAnimation: Namespace.ID
    
    @Binding var onboardingIsActive: Bool
    
    @State var isInitial = true
    
    @State var tapHaptic = false
    
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
    
    var body: some View {
        GeometryReader { geometry in
            if (isInitial) {
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
                            .frame(width: 80)
                            .matchedGeometryEffect(id: "logo", in: launchAnimation)
                            .padding([.top], 70)
                        
                        Text("Welcome")
                            .foregroundStyle(colorScheme == .dark ? .white : .black)
                            .font(Font.custom("Inter-Thin", size: 50))
                            .fontWeight(.thin)
                            .padding([.top], 25)
                            .padding([.bottom], 15)
                        
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 40) {
                            HStack(alignment: .center, spacing: 25) {
                                Image(systemName: "brain")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundStyle(.pink)
                                
                                Text("Made in honor of Alzheimer's disease")
                                    .foregroundStyle(colorScheme == .dark ? .gray : .black)
                                    .font(Font.custom("Inter-Thin", size: (verticalSizeClass == .regular && horizontalSizeClass == .regular) ? 23 : 18))
                                    .fontWeight(.thin)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            HStack(alignment: .center, spacing: 25) {
                                Image(systemName: "lock")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundStyle(colorScheme == .dark ? .white : .black)
                                
                                Text("Clip-it is a quick, easy and secure  way to clip things on your mind.")
                                    .foregroundStyle(colorScheme == .dark ? .gray : .black)
                                    .font(Font.custom("Inter-Thin", size: (verticalSizeClass == .regular && horizontalSizeClass == .regular) ? 23 : 18))
                                    .fontWeight(.thin)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            
                            HStack(alignment: .center, spacing: 25) {
                                Image(systemName: "waveform")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundStyle(.blue)
                                
                                Text("Quickly capture audios around you, like a song you heard on the mall or the voice of a loved one.")
                                    .foregroundStyle(colorScheme == .dark ? .gray : .black)
                                    .font(Font.custom("Inter-Thin", size: (verticalSizeClass == .regular && horizontalSizeClass == .regular) ? 23 : 18))
                                    .fontWeight(.thin)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            
                            HStack(alignment: .center, spacing: 25) {
                                Image(systemName: "camera")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundStyle(.red)
                                
                                Text("Quickly capture pictures around you, like a shirt you liked or that wine you tasted.")
                                    .foregroundStyle(colorScheme == .dark ? .gray : .black)
                                    .font(Font.custom("Inter-Thin", size: (verticalSizeClass == .regular && horizontalSizeClass == .regular) ? 23 : 18))
                                    .fontWeight(.thin)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            
                            HStack(alignment: .center, spacing: 25) {
                                Image(systemName: "note.text")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundStyle(.purple)
                                
                                Text("Write notes on your clips to help you remind.")
                                    .foregroundStyle(colorScheme == .dark ? .gray : .black)
                                    .font(Font.custom("Inter-Thin", size: (verticalSizeClass == .regular && horizontalSizeClass == .regular) ? 23 : 18))
                                    .fontWeight(.thin)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .frame(maxWidth: 600.0)
                        .padding([.leading, .trailing], 40)
                        .padding([.bottom], 15)
                        
                        Spacer()
                        
                        Button() {
                            withAnimation {
                                isInitial = false
                            }
                        } label: {
                            ZStack {
                                Image(colorScheme == .dark ? "GrainyBackgroundLight" : "GrainyBackground")
                                    .resizable()
                                    .scaledToFill()
                                Text("Next")
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
                    }
                }
                .sensoryFeedback(.impact, trigger: tapHaptic)
            } else {
                OnboardingPage(launchAnimation: $launchAnimation.wrappedValue, onboardingIsActive: $onboardingIsActive)
            }
        }
    }
}

#Preview {
    InitialOnboarding(launchAnimation: Namespace().wrappedValue, onboardingIsActive: .constant(true))
}
