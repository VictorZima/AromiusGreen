//
//  CustomActionButton.swift
//  AromiusGreen
//
//  Created by VictorZima on 14/10/2024.
//

import SwiftUI


enum ButtonWidthSize {
    case small, medium, large
}

struct CustomActionButton: View {
    var title: String
    var widthSize: ButtonWidthSize
    var action: (() -> Void)?
    
    @State private var isPressed = false
    
    var body: some View {
            Button(action: {
                action?()
            }) {
                buttonContent
                    .scaleEffect(isPressed ? 0.95 : 1.0)
                    .background(isPressed ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
                    .animation(.easeInOut(duration: 0.2), value: isPressed)
            }
            .padding(.horizontal)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
    
    private var buttonContent: some View {
        Text(NSLocalizedString(title, comment: ""))
            .foregroundColor(.darkBlueItem)
            .frame(width: width(for: widthSize))
            .padding(.vertical, 12)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.darkBlueItem, lineWidth: 1)
            )
    }
    
    private func width(for size: ButtonWidthSize) -> CGFloat {
        switch size {
        case .small: return 150
        case .medium: return 200
        case .large: return 250
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        CustomActionButton(title: "Click me", widthSize: .medium, action: {
            print("Button clicked")
        })
    }
    .padding()
}
