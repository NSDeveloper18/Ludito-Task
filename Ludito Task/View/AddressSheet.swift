//
//  AddressSheet.swift
//  Ludito Task
//
//  Created by Shakhzod Botirov on 07/05/25.
//

import SwiftUI

struct AddressSheet: View {
    @ObservedObject var mapModel: MapModel = .shared
    @Binding var closeSheet: Bool
    @Binding var openAlert: Bool
    let stars: [Color] = [colors.green2, colors.green2, colors.green2, colors.green2, colors.gray2]
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                Rectangle()
                    .foregroundStyle(colors.gray5)
                    .frame(width: 40, height: 4)
                    .clipShape(RoundedRectangle(cornerRadius: 50, style: .continuous))
                Spacer()
            }
            .padding(.top, 8)
            
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Location name")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.black)
                        
                        Spacer()
                    }
                    Text(mapModel.addressMap)
                        .font(.system(size: 16))
                        .foregroundStyle(colors.gray)
                }
                
                Spacer()
                
                Button(action: {
                    closeSheet.toggle()
                }) {
                    Image(systemName: "x.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(colors.gray2)
                }
            }
            .padding(.bottom, 12)
            
            HStack(spacing: 4) {
                ForEach(stars, id: \.self) { color in
                    Image(systemName: "star.fill")
                        .foregroundStyle(color)
                        .font(.system(size: 15))
                        .frame(width: 16, height: 16)
                }
                
                Text("517 оценок")
                    .foregroundStyle(colors.gray)
                    .font(.system(size: 14))
            }
            .frame(height: 20)
            .padding(.bottom, 11)
            
            Button(action: {
                openAlert.toggle()                
            }, label: {
                Text("Добавить в избранное")
                    .foregroundStyle(.white)
                    .font(.system(size: 16, weight: .semibold))
                    .padding(.vertical, 22)
                    .padding(.horizontal, 11)
                    .frame(height: 42)
                    .background(colors.green)
                    .cornerRadius(50)
            })
            .padding(.bottom)
        }
        .padding(.horizontal, 16)
    }
    

}
