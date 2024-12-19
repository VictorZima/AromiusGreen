//
//  CustomNavigationButton.swift
//  AromiusGreen
//
//  Created by VictorZima on 24/10/2024.
//

import SwiftUI

struct CustomNavigationButton<Destination: View>: View {
    var title: String
    var widthSize: ButtonWidthSize
    var destination: Destination

    var body: some View {
        NavigationLink(destination: destination) {
            buttonContent
        }
        .padding(.horizontal)
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
