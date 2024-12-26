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
                Text("info_city_part_1")
                    .foregroundColor(.darkBlueItem)
                    .font(.system(size: 20, weight: .bold))
                + Text("info_city_part_2")
                    .font(.system(size: 18))
                Spacer()
            }
            .padding(16)
            
            HStack(alignment: .top) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(Color.green)
                Text("info_street")
                    .font(.body)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .padding(.bottom)
            
            HStack(alignment: .top) {
                Image(systemName: "clock")
                    .foregroundStyle(Color.green)
                VStack(alignment: .leading) {
                    Text("info_open_days")
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
                    Text("info_call_us")
                        .font(.body)
                    Link("info_number_phone", destination: URL(string: "tel:+972585001976")!)
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

