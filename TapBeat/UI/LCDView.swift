import SwiftUI

/// Shared glowing LCD display component for TapBeat across macOS, iOS, and watchOS.
struct LCDView: View {
    let bpmText: String
    let subtitle: String
    let glowOpacity: Double
    var compact: Bool = false
    var onTap: (() -> Void)? = nil

    private let glowColor = Color(red: 0.45, green: 0.95, blue: 0.85)
    private let wellColor = Color(red: 0.04, green: 0.06, blue: 0.07)
    private let rimColor = Color(white: 0.22)
    private let gradientCenterColor = Color(red: 0.08, green: 0.12, blue: 0.12, opacity: 0.55)
    private let brightDigitColor = Color(red: 0.75, green: 1.0, blue: 0.92)

    init(
        bpmText: String = "---",
        subtitle: String = "SPACE TO TAP",
        glowOpacity: Double = 0.45,
        compact: Bool = false,
        onTap: (() -> Void)? = nil
    ) {
        self.bpmText = bpmText
        self.subtitle = subtitle
        self.glowOpacity = glowOpacity
        self.compact = compact
        self.onTap = onTap
    }

    private var cornerRadius: CGFloat { compact ? 10 : 12 }
    private var digitSize: CGFloat { compact ? 36 : 56 }
    private var digitOffset: CGFloat { compact ? -3 : -6 }
    private var subtitleSize: CGFloat { compact ? 9 : 11 }
    private var subtitleBottomPadding: CGFloat { compact ? 8 : 16 }
    private var shadowRadius: CGFloat { compact ? 8 : 14 }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background Well
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(wellColor)

                // Inner Radial Gradient
                let maxDim = max(geometry.size.width, geometry.size.height)
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        RadialGradient(
                            colors: [gradientCenterColor, wellColor],
                            center: .center,
                            startRadius: 0,
                            endRadius: maxDim * 0.7
                        )
                    )

                // 1px Rim Stroke
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(rimColor, lineWidth: 1)

                // Displayed Digits (layered for glow)
                ZStack {
                    Text(bpmText)
                        .font(.system(size: digitSize, weight: .medium, design: .monospaced))
                        .tracking(2.0)
                        .foregroundColor(glowColor.opacity(glowOpacity))
                        .shadow(color: glowColor.opacity(0.55 * glowOpacity), radius: shadowRadius)

                    Text(bpmText)
                        .font(.system(size: digitSize, weight: .medium, design: .monospaced))
                        .tracking(2.0)
                        .foregroundColor(brightDigitColor.opacity(glowOpacity))
                }
                .offset(y: digitOffset)

                // Subtitle
                VStack {
                    Spacer()
                    Text(subtitle)
                        .font(.system(size: subtitleSize, weight: .regular, design: .monospaced))
                        .tracking(1.5)
                        .foregroundColor(glowColor.opacity(0.35 * max(glowOpacity, 0.5)))
                        .padding(.bottom, subtitleBottomPadding)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onTap?()
            }
        }
    }
}

/// Convenience view that automatically binds LCDView to a TempoSession instance.
struct LCDSessionView: View {
    @ObservedObject var session: TempoSession
    var compact: Bool = false
    var onTap: (() -> Void)? = nil

    var body: some View {
        LCDView(
            bpmText: session.bpmText,
            subtitle: session.subtitle,
            glowOpacity: session.glowOpacity,
            compact: compact,
            onTap: onTap
        )
    }
}
