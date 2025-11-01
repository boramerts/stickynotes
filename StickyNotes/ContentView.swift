//
//  ContentView.swift
//  StickyNotes
//
//  Created by Bora Mert on 1.11.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query private var notes: [Note]
    
    private var hasTrash: Bool {
        notes.contains(where:{$0.isTrash})
    }
    private var isEditingNote: Bool {
        notes.contains(where: { $0.isEditing })
    }
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                VStack {
                    Spacer()
                    HStack {
                        Button {
                            // TODO: handle trash
                        } label: {
                            Image(hasTrash ? "TrashFull" : "TrashEmpty")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .padding([.leading, .bottom], 12)
                                // Bounce by scaling up when hasTrash == true, back to 1.0 when false
                                .scaleEffect(hasTrash ? 1.12 : 1.0)
                                .animation(
                                    .interpolatingSpring(stiffness: 220, damping: 12)
                                        .speed(1.1),
                                    value: hasTrash
                                )
                        }
                        .buttonStyle(.plain)

                        Spacer()
                        
                        Button {
                            createNoteForEditing(screenSize: proxy.size)
                        } label: {
                            Image("Notepad")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .padding([.trailing, .bottom], 12)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .zIndex(0.4)
                
                ZStack {
                    let visibleNotes = notes.filter { !$0.isTrash }
                    
                    // Tap-to-dismiss layer: only active when any note is editing
                    if isEditingNote {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .ignoresSafeArea()
                            .animation(.easeInOut(duration: 0.2), value: isEditingNote)
                            .contentShape(Rectangle()) // full-screen hit area
                            .allowsHitTesting(isEditingNote) // intercept taps only while visible
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    for note in notes where note.isEditing {
                                        note.isEditing = false
                                    }
                                }
                                try? context.save()
                            }
                            .zIndex(0.5)
                    }
                    
                    ForEach(visibleNotes) { note in
                        if note.isEditing {
                            NoteEditorView(note: note, screenSize: proxy.size)
                                .position(CGPoint(x: proxy.size.width / 2,
                                                  y: proxy.size.height * 0.55))
                                .zIndex(6) // higher than the tap layer
                                .transition(
                                    .asymmetric(
                                        insertion: .scale(scale: 0.5, anchor: .center).combined(with: .opacity),
                                        removal: .scale(scale: 0.5, anchor: .center).combined(with: .opacity)
                                    )
                                )
                        } else {
                            StickyNoteView(note: note, screenSize: proxy.size)
                                .position(CGPoint(x: note.x, y: note.y))
                                .zIndex(isEditingNote ? 0.4 : note.zIndex)
                        }
                    }
                }
                .zIndex(0.6)
                .animation(.spring(), value: notes.map { $0.isEditing })
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemBackground))
        }
        .ignoresSafeArea(.keyboard)
    }
    
    func createNoteForEditing(screenSize: CGSize) {
        let note = Note(
            x: screenSize.width / 2,
            y: screenSize.height * 0.25,
            title: "Title",
            body: "Your note goes here...",
            width: 280,
            height: 260,
            isEditing: true,
            zIndex: Date().timeIntervalSince1970 // bring to front
        )
        print(Date().timeIntervalSince1970)
        context.insert(note)
        try? context.save()
    }
}

struct NoteEditorView: View {
    @Environment(\.modelContext) private var context
    @Bindable var note: Note
    var screenSize: CGSize

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                TextField("Title", text: $note.title)
                    .font(.title2).bold()
                Spacer()
                Button {
                    withAnimation(.spring()) {
                        note.isEditing = false
                        note.width = 120
                        note.height = 120
                    }
                    try? context.save()
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }
            }
            TextEditor(text: $note.body)
                .font(.body)
                .frame(height: 140)
                .scrollContentBackground(.hidden)
            Spacer()
        }
        .padding()
        .padding(.horizontal)
        .background(
            Image("StickyNote")
                .resizable()
                .scaledToFill()
        )
        .frame(width: note.width, height: note.height)
        .position(x: screenSize.width / 2, y: screenSize.height * 0.25) // absolute position in the ZStack space
        .zIndex(Date().timeIntervalSince1970)
        .onAppear {
            // Ensure it’s visually on top while editing
            note.zIndex = Date().timeIntervalSince1970
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Note.self, inMemory: true)
}
