//
//  SwiftUIView.swift
//  
//
//  Created by Diego Gutierrez on 26/01/24.
//

import SwiftUI
import AVFoundation

struct PhotoView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @Binding var offsetAnimation: Bool
    @Binding var viewsIconHidden: Bool
    
    @State var isShown = false
    @State var previewIsZoomed = false
    
    @StateObject var cameraController = CameraController()
    
    @State var photoFileName = ""
    @State var saveIsShown = false
    
    @State var flashAnimation = false
    @State var flashMode: AVCaptureDevice.FlashMode = .off
    
    @State var photoCardWidth = 280.0
    @State var photoCardHeight = 310.0
    
    var longPressGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.2)
            .onEnded { _ in
                flashAnimation = true
                
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    flashAnimation = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    cameraController.takePicture(flashMode: flashMode) { fileName in
                        if (fileName != "") {
                            photoFileName = fileName
                            
                            if (previewIsZoomed) {
                                withAnimation {
                                    previewIsZoomed.toggle()
                                }
                                
                                cameraController.updateFrameSize(newSize: CGRect(x: 0.0, y: 0.0, width: photoCardWidth, height: photoCardHeight))
                            }
                            
                            withAnimation {
                                isShown = false
                            }
                            
                            cameraController.disableCamera()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                withAnimation {
                                    saveIsShown = true
                                }
                            }
                        }
                    }
                }
            }
    }
    
    var body: some View {
        GeometryReader { geometry in
            if (saveIsShown) {
                PhotoSaveView(photoFileName: $photoFileName, saveIsShown: $saveIsShown, viewsIconHidden: $viewsIconHidden)
                    .environment(\.modelContext, modelContext)
                    .ignoresSafeArea(.keyboard)
                    .onAppear {
                        withAnimation {
                            viewsIconHidden = true
                        }
                    }
            }
            
            if (!saveIsShown) {
                ZStack {
                    PhotoCard(flashAnimation: $flashAnimation, previewIsZoomed: $previewIsZoomed, flashMode: $flashMode)
                        .ignoresSafeArea(.keyboard)
                        .environmentObject(cameraController)
                        .simultaneousGesture(longPressGesture)
                }
                .ignoresSafeArea(.keyboard)
                .frame(width: geometry.size.width)
                .offset(y: isShown ? (verticalSizeClass == .regular && horizontalSizeClass == .regular) ? geometry.size.height - 400 : geometry.size.height - 200 : (verticalSizeClass == .regular && horizontalSizeClass == .regular) ? geometry.size.height + 150 : geometry.size.height + 50)
                .onAppear() {
                    if (verticalSizeClass == .regular && horizontalSizeClass == .regular) {
                        photoCardWidth = 480.0
                        photoCardHeight = 510.0
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            isShown = true
                        }
                    }
                    
                    cameraController.startCamera()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        cameraController.updateFrameSize(newSize: CGRect(x: 0.0, y: 0.0, width: photoCardWidth, height: photoCardHeight))
                    }
                }
                .onDisappear() {
                    withAnimation {
                        isShown = false
                    }
                    
                    cameraController.disableCamera()
                }
                .onChange(of: offsetAnimation, { oldValue, newValue in
                    if (newValue) {
                        withAnimation {
                            isShown = false
                            
                            if (previewIsZoomed) {
                                withAnimation {
                                    previewIsZoomed.toggle()
                                }
                                
                                cameraController.updateFrameSize(newSize: CGRect(x: 0.0, y: 0.0, width: photoCardWidth, height: photoCardHeight))
                            }
                        }
                    }
                })
                .onChange(of: saveIsShown) { oldValue, newValue in
                    if (!newValue) {
                        withAnimation {
                            isShown = true
                        }
                    }
                }
            }
        }
        .sensoryFeedback(.impact(flexibility: .rigid), trigger: flashAnimation)
    }
}

#Preview {
    PhotoView(offsetAnimation: .constant(true), viewsIconHidden: .constant(true))
}
