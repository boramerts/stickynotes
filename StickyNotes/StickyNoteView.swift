//
//  StickyNoteView.swift
//  StickyNotes
//
//  Created by Bora Mert on 1.11.2025.
//

import SwiftUI
import SwiftData

struct StickyNoteView: View {
    @AppStorage("NoteColor") private var noteColor: String = "yellow"
    @AppStorage("NoteSize") private var noteSize: String = "Normal"
    
    @Environment(\.modelContext) private var context
    @Bindable var note: Note
    var screenSize: CGSize
    
    @State private var offset = CGSize.zero
    @State private var noteScale: CGFloat = 1.0
    @State private var lastScaleValue: CGFloat = 1.0
    @State private var dragScale: CGFloat = 1.0
    @State private var opacity: CGFloat = 1.0
    @State private var rotation: Angle = Angle(degrees: Double.random(in: -5...5))
    @State private var startX: Double = 0
    @State private var startY: Double = 0

    private var frameSide: CGFloat {
        CGFloat(SettingsHandler.shared.getNoteSize(from: noteSize))
    }
    
    private var noteImage: String {
        if note.color == nil {
            SettingsHandler.shared.getNoteColor(from: noteColor)
        } else {
            SettingsHandler.shared.getNoteColor(from: note.color!)
        }
    }
    
    private var bodySize: CGFloat {
        SettingsHandler.shared.getFontSize(from: noteSize)
    }
    
    @State private var isDeleting: Bool = false
    @Binding var isOverTrash: Bool
    
    var body: some View {
        ZStack {
            Image(noteImage)
                .resizable()
                .scaledToFill()
                .aspectRatio(contentMode: .fit)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(note.title.isEmpty ? "Untitled" : note.title)
                        .font(.system(size: bodySize + 4))
                        .bold()
                        .lineLimit(1)
                        .foregroundStyle(.black)
                    Spacer()
                }
                
                Text(note.body.isEmpty ? " " : note.body)
                    .font(.system(size: bodySize))
                    .lineLimit(4)
                    .foregroundStyle(.black)
                
                Spacer()
                
                Text(note.dateAdded.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(size: bodySize - 4))
                    .foregroundStyle(.gray)
            }
            .padding()
        }
        .frame(width: frameSide, height: frameSide)
        .opacity(opacity)
        .scaleEffect(noteScale * dragScale)
        .offset(offset)
        .rotationEffect(rotation)
        .simultaneousGesture(
            MagnifyGesture()
                .onChanged { value in
                    let delta = value.magnification / lastScaleValue
                    noteScale *= delta
                    lastScaleValue = value.magnification
                    
                    // optional clamp
                    noteScale = min(max(noteScale, 0.5), 2.5)
                }
                .onEnded { _ in
                    lastScaleValue = 1.0
                }
        )
        .simultaneousGesture(
            DragGesture()
                .onChanged { gesture in
                    if offset == .zero {
                        startX = note.x
                        startY = note.y
                        note.zIndex = Date().timeIntervalSince1970
                    }
                    
                    offset = gesture.translation
                    
                    let overTrashNow =
                        startX + offset.width <= screenSize.width / 3.4 &&
                        startY + offset.height >= screenSize.height * 0.85
                    
                    isDeleting = overTrashNow
                    
                    if isOverTrash != overTrashNow {
                        withAnimation(.interpolatingSpring(stiffness: 260, damping: 14)) {
                            isOverTrash = overTrashNow
                        }
                    }
                    
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8, blendDuration: 0.2)) {
                        rotation = Angle(degrees: 0)
                        
                        if isDeleting {
                            opacity = 0.80
                            dragScale = 0.95
                        } else {
                            opacity = 1.0
                            dragScale = 1.05
                        }
                    }
                }
                .onEnded { value in
                    note.x = startX + value.translation.width
                    note.y = startY + value.translation.height
                    note.zIndex = Date().timeIntervalSince1970
                    
                    if isDeleting {
                        note.isTrash = true
                    }
                    
                    offset = .zero
                    
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.85, blendDuration: 0.2)) {
                        dragScale = 1.0
                        rotation = Angle(degrees: Double.random(in: -5...5))
                        opacity = 1.0
                    }
                    
                    if isOverTrash {
                        withAnimation(.interpolatingSpring(stiffness: 260, damping: 14)) {
                            isOverTrash = false
                        }
                    }
                    
                    try? context.save()
                }
        )
        .onTapGesture {
            withAnimation(.spring()) {
                note.isEditing = true
                note.width = 280
                note.height = 260
                note.zIndex = Date().timeIntervalSince1970
            }
            try? context.save()
        }
    }
}
