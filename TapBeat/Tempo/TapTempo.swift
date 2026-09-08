import Foundation

/// Instant tap-tempo: BPM after the second tap, mean of last 8 intervals, EMA-smoothed.
struct TapTempo {
    private(set) var timestamps: [CFAbsoluteTime] = []
    private var smoothedBPM: Double?

    /// Minimum interval (~300 BPM) — ignore faster accidental double-fires.
    static let minInterval: CFAbsoluteTime = 60.0 / 300.0
    /// Maximum interval (~30 BPM) — slower gaps are treated as a new phrase by the idle timer.
    static let maxInterval: CFAbsoluteTime = 60.0 / 30.0
    static let windowSize = 8
    /// How much each new reading pulls the displayed BPM (0 = frozen, 1 = raw).
    static let smoothingAlpha = 0.3
    static let idleResetInterval: TimeInterval = 2.0

    var tapCount: Int { timestamps.count }

    /// Raw windowed mean BPM (unsmoothed).
    var rawBPM: Double? {
        guard timestamps.count >= 2 else { return nil }

        var intervals: [CFAbsoluteTime] = []
        for i in 1..<timestamps.count {
            let gap = timestamps[i] - timestamps[i - 1]
            if gap >= Self.minInterval && gap <= Self.maxInterval {
                intervals.append(gap)
            }
        }

        guard !intervals.isEmpty else { return nil }

        let recent = intervals.suffix(Self.windowSize)
        let mean = recent.reduce(0, +) / Double(recent.count)
        let value = 60.0 / mean
        return min(max(value, 30.0), 300.0)
    }

    /// EMA-smoothed BPM used for display.
    var bpm: Double? { smoothedBPM }

    var displayString: String {
        guard let bpm else { return "---" }
        return String(format: "%.1f", bpm)
    }

    /// Soft opacity until we have enough taps for a firmer reading.
    var displayOpacity: CGFloat {
        if timestamps.count < 2 { return 0.45 }
        if timestamps.count < 4 { return 0.72 }
        return 1.0
    }

    mutating func recordTap(at time: CFAbsoluteTime = CFAbsoluteTimeGetCurrent()) {
        if let last = timestamps.last {
            let gap = time - last
            if gap < Self.minInterval {
                return
            }
        }
        timestamps.append(time)
        updateSmoothing()
    }

    mutating func reset() {
        timestamps.removeAll(keepingCapacity: true)
        smoothedBPM = nil
    }

    private mutating func updateSmoothing() {
        guard let raw = rawBPM else {
            smoothedBPM = nil
            return
        }
        if let current = smoothedBPM {
            let a = Self.smoothingAlpha
            smoothedBPM = current * (1.0 - a) + raw * a
        } else {
            // Instant first reading.
            smoothedBPM = raw
        }
    }
}
