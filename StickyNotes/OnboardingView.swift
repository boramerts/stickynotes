//
//  OnboardingView.swift
//  StickyNotes
//
//  Created by Bora Mert on 8.11.2025.
//

import SwiftUI

let onboardingHeaders = [
    "Welcome to StickyNotes!",
    "Drag to create notes",
    "Drag to delete",
    "See all notes & settings"
]

let onboardingTexts = [
    "Let's make taking notes fun again.",
    "Tap the note stack to create a new note and stick it anywhere on the screen.",
    "Drag the note to trash to remove it from the wall.",
    "Tap the trash to see all your notes and open settings to change note color, size and app appearance."
]

struct OnboardingView: View {
    @State private var currentIndex: Int = 0
    private let steps = 4
    @AppStorage("HasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    var body: some View {
        VStack {
            Spacer(minLength: 16)
            TabView(selection: $currentIndex) {
                // Page 0
                textView(
                    header: onboardingHeaders[0],
                    text: onboardingTexts[0]
                )
                .tag(0)

                // Page 1
                textView(
                    header: onboardingHeaders[1],
                    text: onboardingTexts[1]
                )
                .tag(1)

                // Page 2
                textView(
                    header: onboardingHeaders[2],
                    text: onboardingTexts[2]
                )
                .tag(2)

                // Page 3
                textView(
                    header: onboardingHeaders[3],
                    text: onboardingTexts[3]
                )
                .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentIndex)

            Spacer()
            // Stationary image row; scale/opacity vary by step
            HStack {
                Image("TrashEmpty")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding([.leading, .bottom], 12)
                    .scaleEffect(leftScale(for: currentIndex))
                    .opacity(leftOpacity(for: currentIndex))
                    .offset(x:0, y:leftOffset(for: currentIndex))
                    .animation(.spring(response: 0.35, dampingFraction: 0.85), value: currentIndex)

                Spacer()

                Image("NotepadYellow")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110, height: 110)
                    .padding([.trailing, .bottom], 12)
                    .scaleEffect(rightScale(for: currentIndex))
                    .opacity(rightOpacity(for: currentIndex))
                    .offset(x:0, y:rightOffset(for: currentIndex))
                    .animation(.spring(response: 0.35, dampingFraction: 0.85), value: currentIndex)
            }
            
            // Progress + controls under the texts
            VStack(spacing: 12) {
                DotProgress(currentIndex: $currentIndex, steps: steps)

                HStack {
                    Button("Back") {
                        withAnimation(.easeInOut) {
                            currentIndex = max(0, currentIndex - 1)
                        }
                    }
                    .disabled(currentIndex == 0)
                    .opacity(currentIndex == 0 ? 0 : 1)
                    .animation(.easeInOut, value: currentIndex)
                    .buttonStyle(.bordered)

                    Spacer()

                    Button(currentIndex == steps - 1 ? "Get Started" : "Next") {
                        withAnimation(.easeInOut) {
                            if currentIndex < steps - 1 {
                                currentIndex = min(steps - 1, currentIndex + 1)
                            } else {
                                hasSeenOnboarding = true
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .padding(2)
        .background(Color(.appBackground))
    }
    
    @ViewBuilder
    private func textView(header: String, text: String) -> some View {
        VStack {
            Text(header)
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 6)
                .multilineTextAlignment(.center)
            Text(text)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }

    // MARK: - Per-step visual mapping
    
    private func leftOffset(for index: Int) -> CGFloat {
        switch index {
        case 2:
            return -20
        default:
            return 0
        }
    }
    
    private func rightOffset(for index: Int) -> CGFloat {
        switch index {
        case 1:
            return -20
        default:
            return 0
        }
    }

    private func leftScale(for index: Int) -> CGFloat {
        // Emphasize trash on step 2 and 3
        switch index {
        case 2:
            return 1.25
        default:
            return 1.0
        }
    }

    private func rightScale(for index: Int) -> CGFloat {
        // Emphasize notepad on step 1; slightly less on 0 and 3
        switch index {
        case 1:
            return 1.25
        default:
            return 1.0
        }
    }

    private func leftOpacity(for index: Int) -> Double {
        // Slightly dim when not emphasized
        switch index {
        case 2, 3:
            return 1.0
        default:
            return 0.9
        }
    }

    private func rightOpacity(for index: Int) -> Double {
        switch index {
        case 1:
            return 1.0
        case 0, 3:
            return 0.95
        default:
            return 0.9
        }
    }
}

struct DotProgress: View {
    @Binding var currentIndex: Int
    let steps: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0 ..< steps, id: \.self) { index in
                Capsule()
                    .fill(Color.blue.opacity(index == currentIndex ? 1.0 : 0.35))
                    .frame(width: index == currentIndex ? 22 : 10, height: 10)
                    .animation(.easeInOut, value: currentIndex)
                    .accessibilityLabel("Step \(index + 1) of \(steps)")
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            currentIndex = min(max(0, index), steps - 1)
                        }
                    }
            }
        }
    }
}

#Preview {
    OnboardingView()
}
