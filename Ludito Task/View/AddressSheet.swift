//
//  AddressSheet.swift
//  Ludito Task
//
//  Created by Shakhzod Botirov on 07/05/25.
//

import SwiftUI

struct AddressSheet: View {
    @ObservedObject var mapModel: MapModel = .shared
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var closeSheet: Bool
    let colors: [Color] = [Color(hex: "#C9E31F"), Color(hex: "#C9E31F"), Color(hex: "#C9E31F"), Color(hex: "#C9E31F"), Color(hex: "#A7A2A2")]
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                Rectangle()
                    .foregroundStyle(Color(hex: "#D0CFCF"))
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
                        .foregroundStyle(Color(hex: "#B0ABAB"))
                }
                
                Spacer()
                
                Button(action: {
                    closeSheet.toggle()
                }) {
                    Image(systemName: "x.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.gray)
                }
            }
            .padding(.bottom, 12)
            
            HStack(spacing: 4) {
                ForEach(colors, id: \.self) { color in
                    Image(systemName: "star.fill")
                        .foregroundStyle(color)
                        .font(.system(size: 15))
                        .frame(width: 16, height: 16)
                }
                
                Text("517 оценок")
                    .foregroundStyle(Color(hex: "#B0ABAB"))
                    .font(.system(size: 14))
            }
            .frame(height: 20)
            .padding(.bottom, 11)
            
            Button(action: {
                addItem()
            }, label: {
                Text("Добавить в избранное")
                    .foregroundStyle(.white)
                    .font(.system(size: 16, weight: .semibold))
                    .padding(.vertical, 22)
                    .padding(.horizontal, 11)
                    .frame(height: 42)
                    .background(Color(hex: "#5BC250"))
                    .cornerRadius(50)
            })
            .padding(.bottom)
        }
        .padding(.horizontal, 16)
    }
    
    func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.name = "Location Name"
            newItem.address = mapModel.addressMap
            newItem.latitude = mapModel.latitude
            newItem.longitude = mapModel.longitude

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
