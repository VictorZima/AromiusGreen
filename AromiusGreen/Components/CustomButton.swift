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
    var action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
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
        .padding(.horizontal)
    }

    private func width(for size: ButtonWidthSize) -> CGFloat {
        switch size {
        case .small: return 150
        case .medium: return 200
        case .large: return 250
        }
    }
}
