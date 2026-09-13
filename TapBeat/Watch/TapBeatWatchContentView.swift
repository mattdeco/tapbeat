import SwiftUI

struct TapBeatWatchContentView: View {
    @ObservedObject var session: TempoSession
    @State private var isPressing = false

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 6) {
                // Compact LCD card optimized for wrist display
                LCDView(
                    bpmText: session.bpmText,
                    subtitle: session.subtitle,
                    glowOpacity: session.glowOpacity,
                    compact: true
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scaleEffect(isPressing ? 0.96 : 1.0)
                .animation(.spring(response: 0.15, dampingFraction: 0.6), value: isPressing)

                if session.tapCount > 0 {
                    Button(action: {
                        session.reset()
                        HapticsManager.shared.resetFeedback()
                    }) {
                        Text("RESET")
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .tracking(1.0)
                            .foregroundColor(Color(red: 0.45, green: 0.95, blue: 0.85).opacity(0.8))
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 2)
                }
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
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
    }
}
