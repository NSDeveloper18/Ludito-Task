//
//  ViewController.swift
//  Ludito Task
//
//  Created by Shakhzod Botirov on 07/05/25.
//

import SwiftUI

struct ViewController: View {
    @State var view: AppView = .mapView
    var body: some View {
        VStack {
            switch view {
            case .mapView:
                MapView(view: $view)
            case .bookmark:
                SavedAddressesView(view: $view)
            case .profile:
                MapView(view: $view)
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    ViewController()
}
