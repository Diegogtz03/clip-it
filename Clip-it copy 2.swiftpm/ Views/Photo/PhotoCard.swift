//
//  SwiftUIView.swift
//  
//
//  Created by Diego Gutierrez on 06/02/24.
//

import SwiftUI
import AVFoundation
import TipKit

struct DoubleTapTip: Tip {
    var asset: Image? {
        Image(systemName: "camera")
    }
    
    var title: Text {
        Text("Switch Cameras")
    }

    var message: Text? {
        Text("Double tap to switch cameras")
    }
}

struct PhotoCard: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @State private var cameraPosition: AVCaptureDevice.Position = .back
    @State private var updatedSize: Bool = false
    
    @Binding var flashAnimation: Bool
    
    @EnvironmentObject var cameraController: CameraController
    
    @Binding var previewIsZoomed: Bool
    @Binding var flashMode: AVCaptureDevice.FlashMode
    
    @State var photoCardWidth = 280.0
    @State var photoCardHeight = 310.0
    
    @State var expandedPhotoCardWidth = 280.0 * 1.4
    @State var expandedPhotoCardHeight = 330.0
    
    private let doubleTapTip = DoubleTapTip()
    
    var doubleTapGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded { _ in
                doubleTapTip.invalidate(reason: .actionPerformed)
                
                if (cameraPosition == .back) {
                    cameraPosition = .front
                } else {
                    cameraPosition = .back
                }
            }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 15)
                .fill(colorScheme == .dark ? Color(red: 0.85, green: 0.85, blue: 0.85) : Color(red: 0.29, green: 0.29, blue: 0.29))
                .frame(width: photoCardWidth, height: photoCardHeight)
            
            RoundedRectangle(cornerRadius: 10)
                .fill(.white)
                .frame(width: photoCardWidth - 40, height: photoCardHeight - 120)
                .padding(25)
            
            ZStack(alignment: .topTrailing) {
                CameraPreviewView(cameraController: cameraController, cameraPosition: $cameraPosition, updatedSize: $updatedSize)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .gesture(doubleTapGesture)
                    .frame(width: !previewIsZoomed ? photoCardWidth - 40 : expandedPhotoCardWidth, height: !previewIsZoomed ? photoCardHeight - 120 : expandedPhotoCardHeight)
                    .animation(.easeInOut, value: 0.2)
                HStack {
                    Button() {
                        if (flashMode == .off) {
                            withAnimation {
                                flashMode = .on
                            }
                        } else {
                            withAnimation {
                                flashMode = .off
                            }
                        }
                    } label: {
                        ZStack {
                            (Color.gray.opacity(0.4))
                            
                            Image(systemName: flashMode == .on ? "bolt.fill" : "bolt.slash.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .padding(3)
                                .foregroundStyle(.white)

                        }
                        .frame(width: 35, height: 35)
                        .clipShape(Circle())
                        .padding(5)
                    }
                    .contentTransition(.symbolEffect(.replace))
                    
                    Spacer()
                    
                    Button() {
                        withAnimation {
                            previewIsZoomed.toggle()
                        }
                        
                        if (previewIsZoomed) {
                            cameraController.updateFrameSize(newSize: CGRect(x: 0.0, y: 0.0, width: expandedPhotoCardWidth, height: expandedPhotoCardHeight))
                        } else {
                            cameraController.updateFrameSize(newSize: CGRect(x: 0.0, y: 0.0, width: photoCardWidth, height: photoCardHeight))
                        }
                    } label: {
                        ZStack {
                            (Color.gray.opacity(0.4))
                            
                            Image(previewIsZoomed ? "ZoomOut" : "ZoomIn")
                                .resizable()
                                .scaledToFit()
                                .padding(3)
                                .frame(width: 25, height: 25)
                        }
                        .frame(width: 35, height: 35)
                        .clipShape(Circle())
                        .padding(5)
                    }
                }
            }
            .frame(width: !previewIsZoomed ? photoCardWidth - 40 : photoCardWidth * 1.2, height: !previewIsZoomed ? photoCardHeight - 120 : photoCardHeight)
            .padding(25)
            .offset(y: (verticalSizeClass == .regular && horizontalSizeClass == .regular) ? (previewIsZoomed ? -600.0 : 0.0) : (previewIsZoomed ? -400.0 : 0.0))
            .zIndex(10.0)
        }
        .popoverTip(doubleTapTip, arrowEdge: .bottom)
        .shadow(color: .white, radius: flashAnimation ? 12.0 : 0.0)
        .onAppear() {
            if (verticalSizeClass == .regular && horizontalSizeClass == .regular) {
                photoCardWidth = 480.0
                photoCardHeight = 510.0
                
                expandedPhotoCardWidth = 480.0 * 1.4
                expandedPhotoCardHeight = 530.0
            }
        }
        .onDisappear() {
            previewIsZoomed = false
            cameraPosition = .back
        }
    }
}

#Preview {
    PhotoCard(flashAnimation: .constant(true), previewIsZoomed: .constant(true), flashMode: .constant(.on))
}
