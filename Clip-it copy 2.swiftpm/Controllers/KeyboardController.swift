//
//  File.swift
//  
//
//  Created by Diego Gutierrez on 01/02/24.
//

import Foundation
import SwiftUI

struct KeyboardPaddingModifier: ViewModifier {
    @State private var keyboardHeight: CGFloat = 0
    @State var offset: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(.bottom, keyboardHeight)
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                        withAnimation {
                            keyboardHeight = keyboardSize.height - offset
                        }
                    }
                }

                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    withAnimation {
                        keyboardHeight = 0
                    }
                }
            }
            .onDisappear {
                NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
                NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
            }
    }
}

extension View {
    func keyboardAutoPadding(offset: CGFloat) -> some View {
        self.modifier(KeyboardPaddingModifier(offset: offset))
    }
}
