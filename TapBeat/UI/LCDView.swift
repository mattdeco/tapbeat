import AppKit

final class LCDView: NSView {
    var bpmText: String = "---" {
        didSet { needsDisplay = true }
    }

    var subtitle: String = "SPACE TO TAP" {
        didSet { needsDisplay = true }
    }

    var glowOpacity: CGFloat = 0.45 {
        didSet { needsDisplay = true }
    }

    var onTap: (() -> Void)?

    private let glowColor = NSColor(calibratedRed: 0.45, green: 0.95, blue: 0.85, alpha: 1.0)
    private let wellColor = NSColor(calibratedRed: 0.04, green: 0.06, blue: 0.07, alpha: 1.0)
    private let rimColor = NSColor(calibratedWhite: 0.22, alpha: 1.0)

    private var mouseDownLocation: NSPoint?
    private var didDrag = false
    private let dragThreshold: CGFloat = 4

    override var isFlipped: Bool { false }
    override var acceptsFirstResponder: Bool { true }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }

        let bounds = self.bounds.insetBy(dx: 0.5, dy: 0.5)
        let wellPath = NSBezierPath(roundedRect: bounds, xRadius: 12, yRadius: 12)

        wellColor.setFill()
        wellPath.fill()

        rimColor.setStroke()
        wellPath.lineWidth = 1
        wellPath.stroke()

        context.saveGState()
        wellPath.addClip()
        let colors = [
            NSColor(calibratedRed: 0.08, green: 0.12, blue: 0.12, alpha: 0.55).cgColor,
            wellColor.cgColor
        ]
        if let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: colors as CFArray,
            locations: [0, 1]
        ) {
            context.drawRadialGradient(
                gradient,
                startCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                startRadius: 0,
                endCenter: CGPoint(x: bounds.midX, y: bounds.midY),
                endRadius: max(bounds.width, bounds.height) * 0.7,
                options: []
            )
        }
        context.restoreGState()

        let digitFont = NSFont.monospacedDigitSystemFont(ofSize: 56, weight: .medium)
        let subFont = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)

        let bpmString = NSAttributedString(string: bpmText, attributes: [
            .font: digitFont,
            .foregroundColor: glowColor.withAlphaComponent(glowOpacity),
            .kern: 2.0
        ])
        let bpmSize = bpmString.size()
        let bpmOrigin = NSPoint(
            x: bounds.midX - bpmSize.width / 2,
            y: bounds.midY - bpmSize.height / 2 + 6
        )

        let shadow = NSShadow()
        shadow.shadowColor = glowColor.withAlphaComponent(0.55 * glowOpacity)
        shadow.shadowBlurRadius = 14
        shadow.shadowOffset = .zero

        NSAttributedString(string: bpmText, attributes: [
            .font: digitFont,
            .foregroundColor: glowColor.withAlphaComponent(glowOpacity),
            .kern: 2.0,
            .shadow: shadow
        ]).draw(at: bpmOrigin)

        NSAttributedString(string: bpmText, attributes: [
            .font: digitFont,
            .foregroundColor: NSColor(calibratedRed: 0.75, green: 1.0, blue: 0.92, alpha: glowOpacity),
            .kern: 2.0
        ]).draw(at: bpmOrigin)

        let subString = NSAttributedString(string: subtitle, attributes: [
            .font: subFont,
            .foregroundColor: glowColor.withAlphaComponent(0.35 * max(glowOpacity, 0.5)),
            .kern: 1.5
        ])
        let subSize = subString.size()
        subString.draw(at: NSPoint(
            x: bounds.midX - subSize.width / 2,
            y: bounds.minY + 16
        ))
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
