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
    private let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    private let selectionFeedback = UISelectionFeedbackGenerator()
    #endif

    private init() {
        #if os(iOS)
        impactFeedback.prepare()
        #endif
    }

    func tapFeedback() {
        #if os(iOS)
        impactFeedback.impactOccurred()
        #elseif os(watchOS)
        WKInterfaceDevice.current().play(.click)
        #elseif os(macOS)
        NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .default)
        #endif
    }

    func resetFeedback() {
        #if os(iOS)
        selectionFeedback.selectionChanged()
        #elseif os(watchOS)
        WKInterfaceDevice.current().play(.directionDown)
        #endif
    }
}
