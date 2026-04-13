//
//  Item.swift
//  clipboard
//
//  Created by 水月空 on 2026/4/13.
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
