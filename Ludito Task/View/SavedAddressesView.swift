//
//  SavedAddressesView.swift
//  Ludito Task
//
//  Created by Shakhzod Botirov on 07/05/25.
//

import SwiftUI
import CoreData
import YandexMapsMobile

struct SavedAddressesView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Binding var view: AppView
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    var items: FetchedResults<Item>
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("Мои адреса")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.black)
                Spacer()
            }
            .padding(.bottom, 16)
            .padding(.top, 61)
            .background(Color(.white))
            .cornerRadius(8)
            
            VStack {
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(items) { item in
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Text(item.name ?? "No name")
                                        .foregroundStyle(.black)
                                        .font(.system(size: 16, weight: .semibold))
                                        .frame(height: 20)
                                    Spacer()
                                }
                                Text(item.address ?? "No address")
                                    .foregroundStyle(colors.gray)
                                    .font(.system(size: 14, weight: .semibold))
                                    .frame(height: 20)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                delete(item: item)
                            }) {
                                Image("locationHeart")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                            }
                            .frame(height: 74)
                        }
                        .padding(.horizontal, 16)
                        .background(.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(colors.white2, lineWidth: 1)
                        )
                        .padding(.top, 12)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .background(colors.white3)
            
            BottomBar(view: $view)
        }
        .edgesIgnoringSafeArea(.all)
    }
}
