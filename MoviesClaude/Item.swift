//
//  Item.swift
//  MoviesClaude
//
//  Created by Juan Flores S on 16/03/26.
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
