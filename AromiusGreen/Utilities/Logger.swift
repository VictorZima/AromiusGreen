//
//  Logger.swift
//  AromiusGreen
//
//  Created by VictorZima on 14/01/2025.
//

import Foundation

func debugLog(_ message: String) {
    #if DEBUG
    print(message)
    #endif
}
