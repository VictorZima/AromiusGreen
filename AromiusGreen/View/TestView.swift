//
//  TestView.swift
//  AromiusGreen
//
//  Created by VictorZima on 07/07/2024.
//

import SwiftUI

struct TestView: View {
    let columns = Array(repeating: GridItem(.flexible(), spacing: 3, alignment: .leading), count: 2)  // HERE 2
     var body: some View {
         ScrollView {
             LazyVGrid(columns: columns, spacing: 3) {  // HERE 2
                 ForEach((1...10), id: \.self) { number in

                     NavigationLink {
                         
                     } label: {
                         Text("\(number.description) sdfasd asdfdsf dsf wefr werq ")
                             .font(.system(size: 15, weight: .semibold))
                             .foregroundStyle(Color.black)
                             .lineLimit(2)
                             .border(Color.black)
                             .frame(maxWidth: .infinity)
                         
                     }

                 }
             }
             .padding(3)  // HERE 2
         }
     }
}

#Preview {
    TestView()
}
