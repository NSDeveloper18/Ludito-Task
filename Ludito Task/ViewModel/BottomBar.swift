//
//  BottomBar.swift
//  Ludito Task
//
//  Created by Shakhzod Botirov on 07/05/25.
//

import SwiftUI

struct BottomBar: View {
    @Binding var view: AppView
    var body: some View {
        HStack {
            Spacer()
            
            Button(action: {
                withAnimation {
                    view = .bookmark
                }
            }, label: {
                Image("bookmark")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(view == .bookmark ? Color(.black) : Color(.gray))
                    .scaledToFit()
                    .frame(width: 32, height: 32)
            })
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    view = .mapView
                }
            }, label: {
                Image("pin")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(view == .mapView ? Color(.black) : Color(.gray))
                    .scaledToFit()
                    .frame(width: 32, height: 32)
            })
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    view = .profile
                }
            }, label: {
                Image("person")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(view == .profile ? Color(.black) : Color(.gray))
                    .scaledToFit()
                    .frame(width: 32, height: 32)
            })
            
            Spacer()
        }
        .padding(.top, 15)
        .padding(.bottom, 39)
        .padding(.horizontal, 4)
        .background(.white)
        .frame(height: 86)
        .cornerRadius(12)
    }
}
