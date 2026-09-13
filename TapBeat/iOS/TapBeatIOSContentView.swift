import SwiftUI

struct TapBeatIOSContentView: View {
    @ObservedObject var session: TempoSession
    @State private var isPressing = false

    private let backgroundColor = Color(red: 0.03, green: 0.04, blue: 0.05)

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                // Centered LCD Display Card
                LCDView(
                    bpmText: session.bpmText,
                    subtitle: session.subtitle,
                    glowOpacity: session.glowOpacity,
                    compact: false
                )
                .frame(width: 300, height: 160)
                .scaleEffect(isPressing ? 0.97 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressing)
                .shadow(color: Color(red: 0.45, green: 0.95, blue: 0.85).opacity(0.15), radius: 20)

                Text("TAP ANYWHERE")
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color.white.opacity(0.35))
                    .tracking(2.0)

                Spacer()

                // Reset Action
                if session.tapCount > 0 {
                    Button(action: {
                        session.reset()
                        HapticsManager.shared.resetFeedback()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 13, weight: .bold))
                            Text("RESET")
                                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                                .tracking(1.5)
                        }
                        .foregroundColor(Color(red: 0.45, green: 0.95, blue: 0.85).opacity(0.8))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color(white: 0.12))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                        )
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                } else {
                    Color.clear
                        .frame(height: 40)
                }
            }
            .padding(.bottom, 24)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isPressing = true
            session.tap()
            HapticsManager.shared.tapFeedback()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressing = false
            }
        }
        .onAppear {
            #if canImport(UIKit)
            UIApplication.shared.isIdleTimerDisabled = true
            #endif
        }
        .onDisappear {
            #if canImport(UIKit)
            UIApplication.shared.isIdleTimerDisabled = false
            #endif
        }
    }
}
