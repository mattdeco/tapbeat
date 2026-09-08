import AppKit

final class BorderlessKeyWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

final class MainWindowController: NSWindowController {
    private let tempo = TempoSession()
    private var lcdView: LCDView!

    convenience init() {
        let contentRect = NSRect(x: 0, y: 0, width: 280, height: 148)
        let window = BorderlessKeyWindow(
            contentRect: contentRect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.isReleasedWhenClosed = false
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = true
        window.isMovableByWindowBackground = false
        window.collectionBehavior = [.fullScreenNone]
        window.level = .normal
        window.setContentSize(contentRect.size)
        window.minSize = contentRect.size
        window.maxSize = contentRect.size
        window.center()

        self.init(window: window)
        buildContent()
        tempo.onChange = { [weak self] in
            self?.refreshDisplay()
        }
        refreshDisplay()
    }

    private func buildContent() {
        guard let window else { return }

        let root = NSView(frame: NSRect(x: 0, y: 0, width: 280, height: 148))
        root.wantsLayer = true
        root.layer?.backgroundColor = NSColor.clear.cgColor

        let lcd = LCDView(frame: root.bounds)
        lcd.autoresizingMask = [.width, .height]
        lcd.onTap = { [weak self] in
            self?.tempo.tap()
        }
        root.addSubview(lcd)
        lcdView = lcd

        window.contentView = root
    }

    func handleTap() {
        tempo.tap()
    }

    func handleReset() {
        tempo.reset()
    }

    private func refreshDisplay() {
        lcdView.bpmText = tempo.displayString
        lcdView.glowOpacity = tempo.displayOpacity
        if tempo.tapCount == 0 {
            lcdView.subtitle = "SPACE TO TAP"
        } else if tempo.tapCount == 1 {
            lcdView.subtitle = "KEEP TAPPING"
        } else {
            lcdView.subtitle = String(format: "%d TAPS", tempo.tapCount)
        }
    }
}

/// Owns TapTempo plus the idle-reset timer (UI-side session).
final class TempoSession {
    private var engine = TapTempo()
    private var idleTimer: Timer?
    var onChange: (() -> Void)?

    var tapCount: Int { engine.tapCount }
    var displayString: String { engine.displayString }
    var displayOpacity: CGFloat { engine.displayOpacity }

    func tap() {
        engine.recordTap()
        restartIdleTimer()
        onChange?()
    }

    func reset() {
        idleTimer?.invalidate()
        idleTimer = nil
        engine.reset()
        onChange?()
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
