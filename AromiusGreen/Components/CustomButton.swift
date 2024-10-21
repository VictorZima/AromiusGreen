//
//  CustomButton.swift
//  AromiusGreen
//
//  Created by VictorZima on 14/10/2024.
//

import SwiftUI

enum ButtonWidthSize {
    case small, medium, large
}

struct CustomButton: View {
    var title: String
    var widthSize: ButtonWidthSize
    var action: (() -> Void)?
    var destination: (() -> AnyView)?
    
    var body: some View {
        if let destination = destination {
            NavigationLink(destination: destination()) {
                buttonContent
            }
            .padding(.horizontal)
        } else {
            Button(action: {
                action?()
            }) {
                buttonContent
            }
            .padding(.horizontal)
        }
    }
    
    private var buttonContent: some View {
        Text(title)
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
        CustomButton(title: "Click me", widthSize: .medium, action: {
            print("Button clicked")
        })
        
        CustomButton(title: "Go to next", widthSize: .large, destination: {
            AnyView(Text("Next screen"))
        })
    }
    .padding()
}
