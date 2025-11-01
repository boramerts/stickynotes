//
//  Note.swift
//  StickyNotes
//
//  Created by Bora Mert on 1.11.2025.
//

import Foundation
import SwiftData

@Model
final class Note {
    var id: UUID
    var x: Double
    var y: Double
    var title: String
    var body: String
    var isTrash: Bool
    var width: Double
    var height: Double
    var isEditing: Bool
    var zIndex: Double
    
    init(id: UUID = UUID(),
         x: Double = 0,
         y: Double = 0,
         title: String = "",
         body: String = "",
         isTrash: Bool = false,
         width: Double = 120,
         height: Double = 120,
         isEditing: Bool = false,
         zIndex: Double = 0
    ) {
        self.id = id
        self.x = x
        self.y = y
        self.title = title
        self.body = body
        self.isTrash = isTrash
        self.width = width
        self.height = height
        self.isEditing = isEditing
        self.zIndex = zIndex
    }
}
