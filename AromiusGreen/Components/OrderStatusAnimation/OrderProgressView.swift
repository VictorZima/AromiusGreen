//
//  OrderProgressView.swift
//  BattleGame
//
//  Created by VictorZima on 14/12/2024.
//

//
//  OrderProgressView.swift
//  BattleGame
//
//  Created by VictorZima on 14/12/2024.
//

import SwiftUI

struct OrderProgressView: View {
    var currentStatus: OrderStatus
    var statusHistory: [OrderStatusHistory]
    
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
                    .stroke(Color.gray.opacity(0.5), lineWidth: 3)
                    
                    Path { path in
                        path.move(to: CGPoint(x: circleRadius, y: circleRadius))
                        let completedSteps = min(currentStatus.rawValue, OrderStatus.allCases.count)
                        if completedSteps > 1 {
                            let endX = circleRadius + (spacingBetweenCircles + circleDiameter) * CGFloat(completedSteps - 1)
                            path.addLine(to: CGPoint(x: endX, y: circleRadius))
                        }
                    }
                    .stroke(Color.green, lineWidth: 3)
                    
                    ForEach(OrderStatus.allCases, id: \.self) { tab in
                        let index = tab.rawValue - 1
                        let xPosition = circleRadius + (spacingBetweenCircles + circleDiameter) * CGFloat(index)
                        
                        StepView(isCompleted: tab <= currentStatus, title: tab.displayName)
                            .frame(width: circleDiameter, height: circleDiameter)
                            .position(x: xPosition, y: circleRadius)
                        
                        Text(tab.displayName)
                            .font(.caption2)
                            .foregroundColor(tab <= currentStatus ? .green : .gray)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .position(x: xPosition, y: circleRadius + 25)
                        
                        if tab <= currentStatus, let historyItem = getStatusHistory(for: tab) {
                            VStack(spacing: 2) {
                                Text(formatDate(historyItem.date))
                                    .font(.system(size: 9))
                                    .foregroundColor(.gray)
                                
                                Text(formatTime(historyItem.date))
                                    .font(.system(size: 8))
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .position(x: xPosition, y: circleRadius + 50)
                        }
                    }
                }
            }
            .frame(height: 100)
        }
    }
    
    // Функция для получения истории статуса
    private func getStatusHistory(for status: OrderStatus) -> OrderStatusHistory? {
        return statusHistory.first { $0.status == status }
    }
    
    // Функция для форматирования даты
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short  // Например, "12/14/24"
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    // Функция для форматирования времени
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short  // Например, "3:45 PM"
        return formatter.string(from: date)
    }
}

