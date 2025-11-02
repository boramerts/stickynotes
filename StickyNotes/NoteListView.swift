//
//  NoteListView.swift
//  StickyNotes
//
//  Created by Bora Mert on 2.11.2025.
//

import SwiftUI
import SwiftData

struct NoteListView: View {
    @Environment(\.modelContext) private var context
    @Query private var notes: [Note]
    
    private var deletedNotes: [Note] {
        notes.filter { $0.isTrash }
    }
    
    private var allNotes: [Note] {
        notes
    }
    
    let selections: [String] = ["Deleted Notes", "All Notes"]
    @State private var selection: String = "Deleted Notes"
    @State private var showingSettings = false
    @AppStorage("ColorScheme") var appearance: String = "system"
    
    private var filteredNotes: [Note] {
        switch selection {
        case "Deleted Notes":
            return deletedNotes
        case "All Notes":
            return allNotes
        default:
            return deletedNotes
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(selection)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .overlay(alignment: .trailing) {
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30)
                        .foregroundStyle(Color.gray)
                }
                .buttonStyle(.plain) // keep it from affecting layout; remove if you have a custom .glass style
            }
            .padding(.horizontal, 20)
            .padding(.top, 30)
            if filteredNotes.isEmpty {
                ContentUnavailableView(
                    selection == "Deleted Notes" ? "No Deleted Notes" : "No Notes",
                    systemImage: selection == "Deleted Notes" ? "trash" : "note.text",
                    description: Text(selection == "Deleted Notes"
                                      ? "Drag notes to the trash to see them here."
                                      : "Create a new note to get started.")
                )
                .padding()
            } else {
                List(filteredNotes) { note in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(note.title.isEmpty ? "Untitled" : note.title)
                            .font(.headline)
                        if !note.body.isEmpty {
                            Text(note.body)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                        Text(note.dateAdded.formatted(date: .abbreviated, time: .omitted))
                            .foregroundStyle(.secondary)
                            .font(.caption)
                    }
                    .swipeActions {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            context.delete(note)
                        }
                        Button("Recover", systemImage: "arrow.counterclockwise", role: .close) {
                            note.isTrash = false
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.hidden)
            }
            
            Button("Clear Trash", systemImage: "trash.slash", role: .destructive) {
                for note in deletedNotes {
                    context.delete(note)
                }
            }
            .disabled(deletedNotes.isEmpty)
            
            Picker("Selection", selection: $selection) {
                ForEach(selections, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .padding()
        }
        .sheet(isPresented: $showingSettings) {
            NavigationStack {
                SettingsView()
                    .preferredColorScheme(appearance == "system" ? nil : (appearance == "dark" ? .dark : .light))
            }
        }
    }
    
    private func deleteNote() {
        
    }
}

#Preview {
    NoteListView()
        .modelContainer(for: Note.self, inMemory: true)
}
