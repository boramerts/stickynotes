//
//  StickyNotesApp.swift
//  StickyNotes
//
//  Created by Bora Mert on 1.11.2025.
//

import SwiftUI
import SwiftData

@main
struct StickyNotesApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Note.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        UserDefaults.standard.register(defaults: [
            "NoteColor": "yellow",
            "NoteSize": "Normal",
            "AllowRotation": true,
            "ColorScheme": "system"
        ])
    }
    
    @AppStorage("ColorScheme") var appearance: String = "system"

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(appearance == "system" ? nil : (appearance == "dark" ? .dark : .light))
        }
        .modelContainer(sharedModelContainer)
    }
}
