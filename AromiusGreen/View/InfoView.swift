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
            HStack {
                Text("Bat Yam")
                    .foregroundColor(.darkBlueItem)
                    .font(.system(size: 20, weight: .bold))
                + Text(" city")
                    .font(.system(size: 18))
                Spacer()
            }
            .padding(16)
            
            HStack(alignment: .top) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(Color.green)
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
    }
}

#Preview {
    InfoView()
}

