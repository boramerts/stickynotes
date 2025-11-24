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
            "ColorScheme": "system",
            "HasSeenOnboarding": false
        ])
    }
    
    @AppStorage("ColorScheme") var appearance: String = "system"
    @AppStorage("HasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    var body: some Scene {
        WindowGroup {
            // Crossfade + blur replace
            ZStack {
                // Content sits at the back; fades/blur in when onboarding completes
                ContentView()
                    .opacity(hasSeenOnboarding ? 1 : 0)
                    .blur(radius: hasSeenOnboarding ? 0 : 6)
                    .allowsHitTesting(hasSeenOnboarding)
                    .animation(.easeInOut(duration: 0.35), value: hasSeenOnboarding)

                // Onboarding sits on top initially; fades/blur out when done
                OnboardingView()
                    .opacity(hasSeenOnboarding ? 0 : 1)
                    .blur(radius: hasSeenOnboarding ? 8 : 0)
                    .allowsHitTesting(!hasSeenOnboarding)
                    .animation(.easeInOut(duration: 0.35), value: hasSeenOnboarding)
            }
            .preferredColorScheme(appearance == "system" ? nil : (appearance == "dark" ? .dark : .light))
        }
        .modelContainer(sharedModelContainer)
    }
}
