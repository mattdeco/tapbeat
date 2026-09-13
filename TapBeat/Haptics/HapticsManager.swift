import Foundation
#if os(iOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#elseif os(macOS)
import AppKit
#endif

/// Multiplatform haptic feedback provider for tap tempo actions.
final class HapticsManager {
    static let shared = HapticsManager()

    #if os(iOS)
    private let impactFeedback = UIImpactFeedbackGenerator(style: .soft)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    #endif

    private init() {
        #if os(iOS)
        impactFeedback.prepare()
        selectionFeedback.prepare()
        #endif
    }

    func tapFeedback() {
        #if os(iOS)
        impactFeedback.impactOccurred(intensity: 0.75)
        impactFeedback.prepare()
        #elseif os(watchOS)
        WKInterfaceDevice.current().play(.click)
        #elseif os(macOS)
        NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .default)
        #endif
    }

    func resetFeedback() {
        #if os(iOS)
        selectionFeedback.selectionChanged()
        selectionFeedback.prepare()
        #elseif os(watchOS)
        WKInterfaceDevice.current().play(.directionDown)
        #endif
    }
}
