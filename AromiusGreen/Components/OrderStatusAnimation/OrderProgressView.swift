//
//  OrderProgressView.swift
//  BattleGame
//
//  Created by VictorZima on 14/12/2024.
//

import SwiftUI

struct OrderProgressView: View {
    var currentStatus: OrderStatus
    
    var body: some View {
        VStack(spacing: 16) {
            GeometryReader { geometry in
                let width = geometry.size.width
                let stepCount = CGFloat(OrderStatus.allCases.count)
                let circleDiameter: CGFloat = 20
                let circleRadius = circleDiameter / 2
                let spacingBetweenCircles = (width - (circleDiameter * stepCount)) / (stepCount - 1)
                
                ZStack(alignment: .top) {
                    Path { path in
                        path.move(to: CGPoint(x: circleRadius, y: circleRadius))
                        path.addLine(to: CGPoint(x: width - circleRadius, y: circleRadius))
                    }
                    .stroke(Color.gray.opacity(1.0), lineWidth: 3)
                    
                    Path { path in
                        path.move(to: CGPoint(x: circleRadius, y: circleRadius))
                        let completedSteps = min(currentStatus.rawValue, OrderStatus.allCases.count)
                        if completedSteps > 1 {
                            let endX = circleRadius + (spacingBetweenCircles + circleDiameter) * CGFloat(completedSteps - 1)
                            path.addLine(to: CGPoint(x: endX, y: circleRadius))
                        }
                    }
                    .stroke(Color.green, lineWidth: 3)
                    
                    ForEach(OrderStatus.allCases.indices, id: \.self) { index in
                        let xPosition = circleRadius + (spacingBetweenCircles + circleDiameter) * CGFloat(index)
                        
                        StepView(isCompleted: OrderStatus.allCases[index].rawValue <= currentStatus.rawValue, title: OrderStatus.allCases[index].title)
                            .frame(width: circleDiameter, height: circleDiameter)
                            .position(x: xPosition, y: circleRadius)
                        
                        Text(OrderStatus.allCases[index].title)
                            .font(.caption2)
                            .foregroundColor(OrderStatus.allCases[index].rawValue <= currentStatus.rawValue ? .green : .gray)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .position(x: xPosition, y: circleRadius + 25)
                    }
                }
            }
            .frame(height: 60)
        }
    }
}

