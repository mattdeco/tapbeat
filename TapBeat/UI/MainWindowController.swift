import AppKit
import SwiftUI

final class BorderlessKeyWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

/// Container that intercepts mouse events to differentiate click-to-tap from window dragging.
final class DraggableLCDContainerView: NSView {
    var onTap: (() -> Void)?
    private var mouseDownLocation: NSPoint?
    private var didDrag = false
    private let dragThreshold: CGFloat = 4

    override var acceptsFirstResponder: Bool { true }

    override func hitTest(_ point: NSPoint) -> NSView? {
        guard bounds.contains(point) else { return nil }
        return self
    }

    override func mouseDown(with event: NSEvent) {
        mouseDownLocation = event.locationInWindow
        didDrag = false
    }

    override func mouseDragged(with event: NSEvent) {
        guard let start = mouseDownLocation, let window else { return }
        let current = event.locationInWindow
        let dx = current.x - start.x
        let dy = current.y - start.y
        if !didDrag && hypot(dx, dy) < dragThreshold {
            return
        }
        didDrag = true
        var frame = window.frame
        frame.origin.x += event.deltaX
        frame.origin.y -= event.deltaY
        window.setFrameOrigin(frame.origin)
    }

    override func mouseUp(with event: NSEvent) {
        defer {
            mouseDownLocation = nil
            didDrag = false
        }
        if !didDrag, mouseDownLocation != nil {
            onTap?()
        }
    }
}

final class MainWindowController: NSWindowController {
    private let tempo = TempoSession()

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
    }

    private func buildContent() {
        guard let window else { return }

        let container = DraggableLCDContainerView(frame: NSRect(x: 0, y: 0, width: 280, height: 148))
        container.wantsLayer = true
        container.layer?.backgroundColor = NSColor.clear.cgColor
        container.onTap = { [weak self] in
            self?.handleTap()
        }

        let hostingView = NSHostingView(rootView: LCDSessionView(session: tempo))
        hostingView.frame = container.bounds
        hostingView.autoresizingMask = [.width, .height]
        container.addSubview(hostingView)

        window.contentView = container
    }

    func handleTap() {
        tempo.tap()
        HapticsManager.shared.tapFeedback()
    }

    func handleReset() {
        tempo.reset()
        HapticsManager.shared.resetFeedback()
    }
}
