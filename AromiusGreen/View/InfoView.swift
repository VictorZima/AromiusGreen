//
//  InfoView.swift
//  AromiusGreen
//
//  Created by VictorZima on 30/05/2024.
//

import SwiftUI

struct InfoView: View {
    var body: some View {
        VStack {
            Text("**Bat Yam**")
            .font(.system(size: 20))
            .foregroundStyle(Color.darkBlueItem)
            +
            Text(" city")
                .foregroundStyle(Color.primary)
            
            HStack(alignment: .top) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundStyle(Color.green)
                Text("Balfur str, 87")
                    .font(.body)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .padding(.bottom)
            
            HStack(alignment: .top) {
                Image(systemName: "clock")
                    .foregroundStyle(Color.green)
                VStack(alignment: .leading) {
                    Text("Sanday - Thursday: 9:00 - 20:00")
                        .font(.body)
                    Text("Friday: 9:00 - 15:00")
                        .font(.body)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.bottom)
            
            HStack(alignment: .top) {
                Image(systemName: "square.and.pencil.circle")
                    .foregroundStyle(Color.green)
                VStack(alignment: .leading) {
                    Text("Have questions? Call us or write to WhatsApp")
                        .font(.body)
                    Link("058-5001976", destination: URL(string: "tel:+972585001976")!)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            Image("shop2")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top)
    }
}

#Preview {
    InfoView()
}

