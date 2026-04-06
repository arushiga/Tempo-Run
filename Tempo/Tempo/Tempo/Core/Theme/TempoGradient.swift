import SwiftUI

enum TempoGradient {
    static let appBackground = LinearGradient(
        colors: [TempoColor.backgroundTop, Color.white, TempoColor.backgroundBottom],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let hero = LinearGradient(
        colors: [TempoColor.primary, TempoColor.accent],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let success = LinearGradient(
        colors: [TempoColor.secondary, Color.green],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
