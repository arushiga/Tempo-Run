import SwiftUI

enum TempoGradient {
    static let appBackground = LinearGradient(
        colors: [TempoColor.backgroundTop, TempoColor.backgroundBottom],
        startPoint: .top,
        endPoint: .bottom
    )

    static let hero = LinearGradient(
        colors: [TempoColor.surfaceStrong, TempoColor.surfaceStrong],
        startPoint: .top,
        endPoint: .bottom
    )

    static let success = LinearGradient(
        colors: [TempoColor.surfaceMuted, TempoColor.surfaceMuted],
        startPoint: .top,
        endPoint: .bottom
    )
}
