//
//  SettingsHandler.swift
//  StickyNotes
//
//  Created by Bora Mert on 2.11.2025.
//

import Foundation
import SwiftUI
import Combine

@Observable
final class SettingsHandler {
    // MARK: - Singleton
    static let shared = SettingsHandler()

    // MARK: - Storage
    private let defaults: UserDefaults

    // MARK: - Published Settings
    // Backing storage uses UserDefaults; these properties mirror and keep them in sync.
    var noteColor: String {
        didSet { defaults.set(noteColor, forKey: Keys.noteColor) }
    }

    var noteSize: String {
        didSet { defaults.set(noteSize, forKey: Keys.noteSize) }
    }

    var allowRotation: Bool {
        didSet { defaults.set(allowRotation, forKey: Keys.allowRotation) }
    }

    // MARK: - Init
    init(userDefaults: UserDefaults = .standard) {
        self.defaults = userDefaults

        // Register first-run defaults here as a safety net, though you also register them in App init.
        self.defaults.register(defaults: [
            Keys.noteColor: "yellow",
            Keys.noteSize: "Normal",
            Keys.allowRotation: true
        ])

        self.noteColor = userDefaults.string(forKey: Keys.noteColor) ?? "yellow"
        self.noteSize = userDefaults.string(forKey: Keys.noteSize) ?? "Normal"
        self.allowRotation = userDefaults.object(forKey: Keys.allowRotation) as? Bool ?? true
    }
}

// MARK: - Keys
private enum Keys {
    static let noteColor = "NoteColor"
    static let noteSize = "NoteSize"
    static let allowRotation = "AllowRotation"
}

// MARK: - Color Mapping
extension SettingsHandler {

    // The canonical set of simple color keys your app understands.
    // If you add more in assets, extend this list.
    var supportedColors: [String] { ["yellow", "blue", "green", "pink", "orange"] }

    // Convert simple color key to "N{color}" asset used in SettingsView color circles.
    func getCircleColor(from simple: String) -> String {
        let key = normalize(simple)
        return "N\(key)"
    }

    // Convert to sticky note background image asset name, e.g., "StickyNoteYellow"
    func getNoteColor(from simple: String) -> String {
        let cap = capitalize(simple)
        return "StickyNote\(cap)"
    }

    // Convert to notepad icon asset name, e.g., "NotepadYellow"
    func getNotepadColor(from simple: String) -> String {
        let cap = capitalize(simple)
        return "Notepad\(cap)"
    }

    // Convert to SwiftUI Color using the "N{color}" asset.
    func circleColor(from simple: String) -> Color {
        Color(getCircleColor(from: simple))
    }
    
    func getFontSize(from setting: String) -> CGFloat {
        switch setting {
        case "Normal":
            return 14
        case "Large":
            return 20
        case "Small":
            return 10
        default:
            return 14
        }
    }
    
    func getNoteSize(from setting: String) -> Int {
        switch setting {
        case "Normal":
            return 120
        case "Large":
            return 140
        case "Small":
            return 110
        default:
            return 120
        }
    }

    // Helpers
    private func normalize(_ simple: String) -> String {
        let key = simple.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return supportedColors.contains(key) ? key : "yellow"
    }

    private func capitalize(_ simple: String) -> String {
        let key = normalize(simple)
        return key.prefix(1).uppercased() + key.dropFirst()
    }
}

// MARK: - SwiftUI Helpers
extension SettingsHandler {
    // Bindings to integrate with SwiftUI views without @AppStorage.
    // Example usage:
    // Text("Color: \(settings.noteColor)")
    // Picker(selection: settings.bindingForNoteColor, ...) { ... }
    var bindingForNoteColor: Binding<String> {
        Binding(
            get: { self.noteColor },
            set: { self.noteColor = $0 }
        )
    }

    var bindingForNoteSize: Binding<String> {
        Binding(
            get: { self.noteSize },
            set: { self.noteSize = $0 }
        )
    }

    var bindingForAllowRotation: Binding<Bool> {
        Binding(
            get: { self.allowRotation },
            set: { self.allowRotation = $0 }
        )
    }
}
