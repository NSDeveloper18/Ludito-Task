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
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            if viewModel.isLoading {
                ProgressView("Поиск...")
                    .padding()
            }
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
            
            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    
                    Rectangle()
                        .frame(width: UIScreen.main.bounds.size.width,height: 2)
                        .foregroundStyle(colors.white2)
                    
                    ForEach(viewModel.suggestions) { suggestion in
                        HStack(spacing: 12) {
                            Image("pin")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(colors.gray6)
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(suggestion.title.text)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.black)
                                
                                if let subtitle = suggestion.subtitle?.text {
                                    Text(subtitle)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(colors.gray)
                                }
                            }
                            .padding(.vertical, 5)
                            
                            Spacer()
                        }
                        .frame(height: 42)
                        .padding(.horizontal, 16)
                        
                        Rectangle()
                            .frame(width: UIScreen.main.bounds.size.width,height: 2)
                            .foregroundStyle(colors.white2)
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
            
            Spacer()
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(.white)
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear() {
            isKeyboardFocused = true
        }
    }
}
