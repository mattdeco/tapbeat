import Foundation
import Combine
import CoreGraphics

/// Owns TapTempo plus the idle-reset timer and publishes UI state for SwiftUI & AppKit.
final class TempoSession: ObservableObject {
    @Published private(set) var bpmText: String = "---"
    @Published private(set) var subtitle: String = defaultPromptSubtitle
    @Published private(set) var glowOpacity: Double = 0.45
    @Published private(set) var tapCount: Int = 0

    private var engine = TapTempo()
    private var idleTimer: Timer?
    var onChange: (() -> Void)?

    static var defaultPromptSubtitle: String {
        #if os(macOS)
        return "SPACE TO TAP"
        #else
        return "TAP TO START"
        #endif
    }

    init() {
        updateState()
    }

    var displayString: String { bpmText }
    var displayOpacity: CGFloat { CGFloat(glowOpacity) }

    func tap() {
        engine.recordTap()
        updateState()
        restartIdleTimer()
        onChange?()
    }

    func reset() {
        idleTimer?.invalidate()
        idleTimer = nil
        engine.reset()
        updateState()
        onChange?()
    }

    private func updateState() {
        bpmText = engine.displayString
        glowOpacity = Double(engine.displayOpacity)
        tapCount = engine.tapCount

        if tapCount == 0 {
            subtitle = Self.defaultPromptSubtitle
        } else if tapCount == 1 {
            subtitle = "KEEP TAPPING"
        } else {
            subtitle = String(format: "%d TAPS", tapCount)
        }
    }

    private func restartIdleTimer() {
        idleTimer?.invalidate()
        idleTimer = Timer.scheduledTimer(
            withTimeInterval: TapTempo.idleResetInterval,
            repeats: false
        ) { [weak self] _ in
            self?.reset()
        }
    }
}
