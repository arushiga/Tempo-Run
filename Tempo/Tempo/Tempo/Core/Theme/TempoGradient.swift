import SwiftUI

enum TempoGradient {
    static let appBackground = LinearGradient(
        colors: [TempoColor.backgroundTop, TempoColor.backgroundBottom],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let hero = LinearGradient(
        colors: [TempoColor.primary.opacity(0.95), TempoColor.secondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let success = LinearGradient(
        colors: [TempoColor.warmAccent, TempoColor.secondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
