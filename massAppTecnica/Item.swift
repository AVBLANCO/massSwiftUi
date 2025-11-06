//
//  Item.swift
//  massAppTecnica
//
//  Created by Victor Manuel Blanco Mancera on 5/11/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
