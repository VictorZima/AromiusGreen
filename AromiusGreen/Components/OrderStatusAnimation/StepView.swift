//
//  StepView.swift
//  BattleGame
//
//  Created by VictorZima on 14/12/2024.
//

import SwiftUI

struct StepView: View {
    var isCompleted: Bool
    var title: String
    
    var body: some View {
        ZStack {
            if isCompleted {
                Circle()
                    .fill(Color.green)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .font(.system(size: 12, weight: .bold))
                    )
            } else {
                Circle()
                    .fill(Color.gray.opacity(1.0))
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .fill(Color.white)
                            .frame(width: 13, height: 13)
                    )
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isCompleted)
    }
}

