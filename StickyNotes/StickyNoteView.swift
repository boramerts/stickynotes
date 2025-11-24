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
    
    @State private var offset = CGSize.zero
    @State private var scale: CGFloat = 1.0
    @State private var opacity: CGFloat = 1.0
    @State private var rotation: Angle = Angle(degrees: Double.random(in: -5...5))
    @State private var startX: Double = 0
    @State private var startY: Double = 0

    private var frameSide: CGFloat {
        CGFloat(SettingsHandler.shared.getNoteSize(from: noteSize))
    }
    
    private var noteImage: String {
        SettingsHandler.shared.getNoteColor(from: noteColor)
    }
    
    private var bodySize: CGFloat {
        SettingsHandler.shared.getFontSize(from: noteSize)
    }
    
    @Environment(\.modelContext) private var context
    @Bindable var note: Note
    var screenSize: CGSize
    
    @State private var isDeleting: Bool = false
    // New: bind to ContentView’s live hover state
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
                        .font(.system(size: bodySize + 4)).bold()
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
        .offset(offset)
        .rotationEffect(rotation)
        .scaleEffect(scale)
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    // On first movement, capture the starting absolute coordinates from the model.
                    if offset == .zero {
                        startX = note.x
                        startY = note.y
                        // Bring to front as soon as drag begins
                        note.zIndex = Date().timeIntervalSince1970
                    }
                    offset = gesture.translation
                    
                    // Same region you used for deletion (bottom-left area where trash sits)
                    let overTrashNow = startX + offset.width <= screenSize.width / 3.4
                    && startY + offset.height >= screenSize.height * 0.85
                    
                    isDeleting = overTrashNow
                    // Publish to ContentView to animate the trash can scale
                    if isOverTrash != overTrashNow {
                        withAnimation(.interpolatingSpring(stiffness: 260, damping: 14)) {
                            isOverTrash = overTrashNow
                        }
                    }
                    
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8, blendDuration: 0.2)) {
                        rotation = Angle(degrees: 0)
                        scale = 1.05
                        if isDeleting {
                            opacity = 0.80
                            scale = 0.95
                        } else {
                            opacity = 1.0
                            scale = 1.05
                        }
                    }
                }
                .onEnded { value in
                    // Commit new absolute position
                    note.x = startX + value.translation.width
                    note.y = startY + value.translation.height
                    
                    // Keep it on top after dropping as well
                    note.zIndex = Date().timeIntervalSince1970
                    
                    if isDeleting {
                        note.isTrash = true
                    }
                    
                    // Reset transient visuals
                    offset = .zero
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.85, blendDuration: 0.2)) {
                        scale = 1.0
                        rotation = Angle(degrees: Double.random(in: -5...5))
                    }
                    
                    // Clear hover state on end
                    if isOverTrash {
                        withAnimation(.interpolatingSpring(stiffness: 260, damping: 14)) {
                            isOverTrash = false
                        }
                    }
                    
                    // Persist
                    try? context.save()
                }
        )
        .onTapGesture {
            withAnimation(.spring()) {
                note.isEditing = true
                note.width = 280
                note.height = 260
                // Also bring to front when entering edit
                note.zIndex = Date().timeIntervalSince1970
            }
            try? context.save()
        }
    }
}

