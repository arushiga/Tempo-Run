import SwiftUI

enum TempoColor {
    static let ink = Color(red: 0.09, green: 0.12, blue: 0.19)
    static let slate = Color(red: 0.31, green: 0.37, blue: 0.49)
    static let primary = Color(red: 0.16, green: 0.47, blue: 0.91)
    static let secondary = Color(red: 0.39, green: 0.73, blue: 0.98)
    static let accent = Color(red: 0.98, green: 0.52, blue: 0.24)
    static let warmAccent = Color(red: 0.18, green: 0.72, blue: 0.56)
    static let surface = Color(red: 0.95, green: 0.97, blue: 1.0).opacity(0.9)
    static let surfaceStrong = Color.white.opacity(0.96)
    static let line = primary.opacity(0.14)
    static let backgroundTop = Color.white
    static let backgroundBottom = Color(red: 0.92, green: 0.96, blue: 1.0)
}
