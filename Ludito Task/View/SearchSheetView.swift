//
//  SearchSheetView.swift
//  Ludito Task
//
//  Created by Shakhzod Botirov on 07/05/25.
//

import SwiftUI

struct SearchSheetView: View {
    @StateObject private var viewModel = YandexSearchViewModel()
    @FocusState var isKeyboardFocused: Bool
    var body: some View {
        VStack {
            HStack(spacing: 9) {
                Image("magnify")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .padding(.leading, 12)
                
                TextField("Поиск...", text: $viewModel.searchText)
                    .focused($isKeyboardFocused)
                    .foregroundStyle(Color(.black))
                    .font(.system(size: 16, weight: .bold))
                    .frame(height: 20)
                    .padding(.vertical)
                
                Spacer()
                
                if viewModel.searchText != "" {
                    Button(action: {
                        viewModel.searchText = ""
                    }, label: {
                        Image(systemName: "x.circle.fill")
                            .foregroundStyle(Color(.gray))
                            .font(.system(size: 16))
                    })
                    .padding(.trailing, 16)
                }
            }
            .background(colors.gray4)
            .frame(height: 48)
            .cornerRadius(10)
            .padding(8)
            .background(.white)
            .frame(height: 64)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(colors.white2, lineWidth: 1)
            )
            .padding(16)
            
            
            
            if viewModel.isLoading {
                ProgressView("Поиск...")
                    .padding()
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
            
            ForEach(viewModel.features) { feature in
                HStack(spacing: 12) {
                    Image("location")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(colors.gray6)
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(feature.properties.companyMetaData.name)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.black)
                        
                        Text(feature.properties.companyMetaData.address)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(colors.gray)
                    }
                    .padding(.vertical, 5)
                    
                    Spacer()
                }
            }
            
            Spacer()
        }
        .background(colors.white2)
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear() {
            isKeyboardFocused = true
        }
    }
}
