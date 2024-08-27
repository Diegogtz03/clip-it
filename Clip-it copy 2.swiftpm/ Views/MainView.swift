//
//  SwiftUIView.swift
//  
//
//  Created by Diego Gutierrez on 25/01/24.
//

import SwiftUI

struct MainView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) var modelContext
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @State var launchAnimation: Namespace.ID
    
    @State var offsetAnimation = false
    @State var historyIsOpen = false
    @State var iconRotationHistory = 15.0
    @State var iconScaleHistory = 0.0
    @State var iconRotationHome = 15.0
    @State var iconScaleHome = 0.0
    
    @State var historyOpacity = false
    
    @State var btnIsBlocked = false
    @State var viewsIconHidden = false
    
    @State var selection = 0
    
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
                    .onTapGesture {
                        dismissKeyboard()
                    }
                
                Button() {
                    if (historyIsOpen) {
                        btnIsBlocked = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            btnIsBlocked = false
                        }
                        
                        withAnimation {
                            offsetAnimation = false
                            historyOpacity = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            historyIsOpen.toggle()
                        }
                    } else {
                        btnIsBlocked = true
                        
                        withAnimation {
                            offsetAnimation = true
                            historyOpacity = false
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            historyIsOpen.toggle()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                btnIsBlocked = false
                            }
                        }
                    }
                } label: {
                    if (offsetAnimation) {
                        Image(colorScheme == .dark ? "HomeIconDark" : "HomeIconLight")
                            .resizable()
                            .scaledToFit()
                            .frame(width: (verticalSizeClass == .regular && horizontalSizeClass == .regular) ? 75 : 60)
                            .padding([.top], (verticalSizeClass == .regular && horizontalSizeClass == .regular) ? 25 : 15)
                            .rotationEffect(.degrees(iconRotationHome))
                            .scaleEffect(iconScaleHome)
                            .onAppear() {
                                withAnimation {
                                    iconRotationHome = 0.0
                                    iconScaleHome = 1.0
                                }
                            }
                            .onDisappear() {
                                withAnimation {
                                    iconRotationHome = 15.0
                                    iconScaleHome = 0.0
                                }
                            }
                    } else {
                        Image(colorScheme == .dark ? "HistoryIconDark" : "HistoryIconLight")
                            .resizable()
                            .scaledToFit()
                            .frame(width: (verticalSizeClass == .regular && horizontalSizeClass == .regular) ? 75 : 60)
                            .padding([.top], (verticalSizeClass == .regular && horizontalSizeClass == .regular) ? 25 : 15)
                            .rotationEffect(.degrees(iconRotationHistory))
                            .scaleEffect(iconScaleHistory)
                            .onAppear() {
                                withAnimation {
                                    iconRotationHistory = 0.0
                                    iconScaleHistory = 1.0
                                }
                            }
                            .onDisappear() {
                                withAnimation {
                                    iconRotationHistory = 15.0
                                    iconScaleHistory = 0.0
                                }
                            }
                    }
                }
                .disabled(btnIsBlocked)
                .opacity(viewsIconHidden ? 0.0 : 1.0)
                .scaleEffect(viewsIconHidden ? 0.0 : 1.0)
                .position(x: geometry.size.width - 60, y: 0)
                .sensoryFeedback(.selection, trigger: offsetAnimation)
                .padding([.top], (verticalSizeClass == .regular && horizontalSizeClass == .regular) ? 40 : 30)
                .onChange(of: viewsIconHidden) { oldValue, newValue in
                    withAnimation {
                        viewsIconHidden = newValue
                    }
                }
                
                VStack(alignment: .center) {
                    Image(colorScheme == .dark ? "ClipItLogo" : "ClipItLogoLight")
                        .resizable()
                        .scaledToFit()
                        .frame(width: (verticalSizeClass == .regular && horizontalSizeClass == .regular) ? 45 : 35)
                        .padding([.top], (verticalSizeClass == .regular && horizontalSizeClass == .regular) ? 25 : 15)
                        .matchedGeometryEffect(id: "logo", in: launchAnimation)
                        .ignoresSafeArea(.keyboard)
                    
                    Spacer()
                    
                    if (historyIsOpen) {
                        HistoryView(opacityAnimation: $historyOpacity)
                            .environment(\.modelContext, modelContext)
                    } else {
                        TabView(selection: $selection) {
                            AudioView(offsetAnimation: $offsetAnimation, viewsIconHidden: $viewsIconHidden)
                                .tag(0)
                                .environment(\.modelContext, modelContext)
                            
                            PhotoView(offsetAnimation: $offsetAnimation, viewsIconHidden: $viewsIconHidden)
                                .tag(1)
                                .environment(\.modelContext, modelContext)
                        }
                        .ignoresSafeArea()
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        
                    }
                }
            }
            .ignoresSafeArea(.keyboard)
        }
    }
}

//#Preview {
//    MainView()
//}
