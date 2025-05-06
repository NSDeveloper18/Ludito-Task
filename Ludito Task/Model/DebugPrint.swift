//
//  DebugPrint.swift
//  Ludito Task
//
//  Created by Shakhzod Botirov on 07/05/25.
//

import Foundation

func DebugPrint(_ prints: Any) {
    #if DEBUG
    print(prints)
    #endif
}
