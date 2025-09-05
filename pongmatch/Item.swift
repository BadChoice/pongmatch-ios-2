//
//  Item.swift
//  pongmatch
//
//  Created by Jordi Puigdellívol on 5/9/25.
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
