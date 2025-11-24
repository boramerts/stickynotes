//
//  ContentView.swift
//  StickyNotes
//
//  Created by Bora Mert on 1.11.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("NoteColor") private var noteColor: String = "yellow"
    @AppStorage("NoteSize") private var noteSize: String = "Normal"
    @AppStorage("ColorScheme") var appearance: String = "system"
    
    @Environment(\.modelContext) private var context
    @Query private var notes: [Note]
    
    private var hasTrash: Bool {
        notes.contains(where:{$0.isTrash})
    }
    private var isEditingNote: Bool {
        notes.contains(where: { $0.isEditing })
    }
    
    private var frameSide: CGFloat {
        CGFloat(SettingsHandler.shared.getNoteSize(from: noteSize))
    }
    
    private var noteImage: String {
        SettingsHandler.shared.getNoteColor(from: noteColor)
    }
    
    private var notepadImage: String {
        SettingsHandler.shared.getNotepadColor(from: noteColor)
    }
    
    private var bodySize: CGFloat {
        SettingsHandler.shared.getFontSize(from: noteSize)
    }
    
    @State var shouldPresentList = false
    // New: live drag-over-trash signal from any note
    @State private var isOverTrash: Bool = false
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                VStack {
                    Spacer()
                    HStack {
                        Button {
                            shouldPresentList.toggle()
                        } label: {
                            Image(hasTrash ? "TrashFull" : "TrashEmpty")
                                .resizable()
                                .scaledToFit()
                                .frame(width: frameSide, height: frameSide)
                                .padding([.leading, .bottom], 12)
                                // Bounce by scaling up when hasTrash == true, back to 1.0 when false
//                                .scaleEffect(hasTrash ? 1.12 : 1.0)
//                                .animation(
//                                    .interpolatingSpring(stiffness: 220, damping: 12)
//                                        .speed(1.1),
//                                    value: hasTrash
//                                )
                                // New: live scale while a note is hovering over trash
                                .scaleEffect(isOverTrash ? 1.25 : 1.0)
                                .animation(
                                    .interpolatingSpring(stiffness: 260, damping: 14),
                                    value: isOverTrash
                                )
                        }
                        .buttonStyle(.plain)
                        .sheet(isPresented: $shouldPresentList) {
                            NoteListView()
                                .presentationDragIndicator(.visible)
                                .preferredColorScheme(appearance == "system" ? nil : (appearance == "dark" ? .dark : .light))
                        }

                        Spacer()
                        
                        Button {
                            createNoteForEditing(screenSize: proxy.size)
                        } label: {
                            Image(notepadImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .padding(.bottom, 12)
                                .padding(.trailing, 16)
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
                            NoteEditorView(note: note, screenSize: proxy.size, noteImage: noteImage)
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
                            StickyNoteView(note: note, screenSize: proxy.size, isOverTrash: $isOverTrash)
                                .position(CGPoint(x: note.x, y: note.y))
                                .zIndex(isEditingNote ? 0.4 : note.zIndex)
                        }
                    }
                }
                .zIndex(0.6)
                .animation(.spring(), value: notes.map { $0.isEditing })
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.appBackground))
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
            zIndex: Date().timeIntervalSince1970, // bring to front
            dateAdded: Date.now
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
    var noteImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                TextField("Title", text: $note.title)
                    .font(.title2).bold()
                    .foregroundStyle(.black)
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
                .foregroundStyle(.black)
            Spacer()
        }
        .padding()
        .padding(.horizontal)
        .background(
            Image(noteImage)
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

