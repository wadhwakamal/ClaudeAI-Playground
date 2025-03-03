//
//  Item.swift
//  ClaudeAI-DemoApp
//
//  Created by Kamal Wadhwa on 02/03/25.
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
