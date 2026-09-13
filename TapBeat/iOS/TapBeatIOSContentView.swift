import SwiftUI

#if canImport(UIKit)
import UIKit

/// Ultra-low latency full-screen touch catcher that responds on touchesBegan (finger touch-down).
private struct LowLatencyTapCatcher: UIViewRepresentable {
    var onTouchDown: () -> Void

    func makeUIView(context: Context) -> TapCaptureUIView {
        let view = TapCaptureUIView()
        view.onTouchDown = onTouchDown
        return view
    }

    func updateUIView(_ uiView: TapCaptureUIView, context: Context) {
        uiView.onTouchDown = onTouchDown
    }

    final class TapCaptureUIView: UIView {
        var onTouchDown: (() -> Void)?

        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .clear
            isMultipleTouchEnabled = false
            isUserInteractionEnabled = true
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            super.touchesBegan(touches, with: event)
            onTouchDown?()
        }
    }
}
#endif

struct TapBeatIOSContentView: View {
    @ObservedObject var session: TempoSession
    @State private var isFlashing = false

    // LCD Palette matching the glowing instrument styling
    private let wellColor = Color(red: 0.04, green: 0.06, blue: 0.07)
    private let gradientCenterColor = Color(red: 0.08, green: 0.12, blue: 0.12, opacity: 0.55)
    private let glowColor = Color(red: 0.45, green: 0.95, blue: 0.85)
    private let brightDigitColor = Color(red: 0.75, green: 1.0, blue: 0.92)

    private var effectiveGlowOpacity: Double {
        let base = session.glowOpacity
        return isFlashing ? min(1.0, base + 0.22) : base
    }

    var body: some View {
        GeometryReader { geometry in
            let maxDim = max(geometry.size.width, geometry.size.height)

            ZStack {
                // Full viewport LCD well background
                wellColor
                    .ignoresSafeArea()

                // Full viewport radial gradient
                RadialGradient(
                    colors: [gradientCenterColor, wellColor],
                    center: .center,
                    startRadius: 0,
                    endRadius: maxDim * 0.7
                )
                .ignoresSafeArea()

                #if canImport(UIKit)
                // Ultra-low latency touch receiver (fires on touch-down)
                LowLatencyTapCatcher {
                    handleTap()
                }
                .ignoresSafeArea()
                #endif

                // Centered LCD BPM Numbers and Subtitle
                VStack(spacing: 16) {
                    ZStack {
                        // Cyan glow layer
                        Text(session.bpmText)
                            .font(.system(size: 84, weight: .medium, design: .monospaced))
                            .tracking(2.5)
                            .foregroundColor(glowColor.opacity(effectiveGlowOpacity))
                            .shadow(color: glowColor.opacity(0.6 * effectiveGlowOpacity), radius: 22)

                        // Crisp bright foreground digit layer
                        Text(session.bpmText)
                            .font(.system(size: 84, weight: .medium, design: .monospaced))
                            .tracking(2.5)
                            .foregroundColor(brightDigitColor.opacity(effectiveGlowOpacity))
                    }

                    Text(session.subtitle)
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .tracking(2.0)
                        .foregroundColor(glowColor.opacity(0.45 * max(effectiveGlowOpacity, 0.5)))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .allowsHitTesting(false)

                // Reset Action at bottom
                VStack {
                    Spacer()

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
                            .foregroundColor(glowColor.opacity(0.8))
                            .padding(.horizontal, 22)
                            .padding(.vertical, 11)
                            .background(
                                Capsule()
                                    .fill(Color(white: 0.12))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.16), lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.bottom, 24)
                        .transition(.opacity.combined(with: .scale(scale: 0.92)))
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: session.tapCount > 0)
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

    private func handleTap() {
        session.tap()
        HapticsManager.shared.tapFeedback()

        isFlashing = true
        withAnimation(.easeOut(duration: 0.14)) {
            isFlashing = false
        }
    }
}
