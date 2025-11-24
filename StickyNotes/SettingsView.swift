//
//  SettingsView.swift
//  StickyNotes
//
//  Created by Bora Mert on 2.11.2025.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("NoteColor") private var noteColor: String = "yellow"
    @AppStorage("NoteSize") private var noteSize: String = "Normal"
    @AppStorage("ColorScheme") private var appearance: String = "system"

    private let colors = ["yellow", "blue", "green", "pink", "orange"]
    private let sizes = ["Small", "Normal", "Large"]
    private let appearances = ["system", "dark", "light"]
    
    private let colorNames = [
        "yellow": "Nyellow",
        "blue" : "Nblue",
        "orange" : "Norange",
        "pink" : "Npink",
        "green" : "Ngreen"
    ]

    var body: some View {
        Form {
            Section("Note Color") {
                VStack {
                    HStack {
                        Spacer()
                        ForEach(colors, id: \.self) { color in
                            let circleColor = Color(SettingsHandler.shared.getCircleColor(from: color))

                            VStack(alignment: .center) {
                                Circle()
                                    .fill(circleColor)
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.black, lineWidth: 2)
                                    )
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(noteColor == color ? Color.gray.opacity(0.2) : Color.clear)
                            )
                            .onTapGesture {
                                noteColor = color
                            }
                        }
                        Spacer()
                    }
                    
                    Image(SettingsHandler.shared.getNotepadColor(from: noteColor))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150)
                        .padding(.leading)
                        .padding(.top, 5)
                }
            }
            .listRowBackground(Color.clear)
                
            Section("Note Size") {
                Picker("Size", selection: $noteSize) {
                    ForEach(sizes, id: \.self) { size in
                        Text(size).tag(size)
                    }
                }
            }
            
            Section("Appearance") {
                Picker("Mode", selection: $appearance) {
                    ForEach(appearances, id: \.self) { color in
                        Text(color.capitalized).tag(color)
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .scrollDisabled(true)
        Text("StickyNotes by Bora Mert | 2025")
            .font(.caption)
            .padding(.top, 3)
    }
}

#Preview {
    SettingsView()
}
