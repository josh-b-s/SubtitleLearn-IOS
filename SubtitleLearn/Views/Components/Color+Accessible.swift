import SwiftUI
import UIKit

extension Color {
    /// Status colours safe to use for text. The bright system shades are under 4.5:1 on a light background.
    /// Dark mode keeps the system shade, and Increased Contrast switches to a deeper one.
    static let successText = statusText(light: (0.00, 0.50, 0.20), high: (0.00, 0.38, 0.13), dark: .systemGreen)
    static let warningText = statusText(light: (0.70, 0.35, 0.00), high: (0.55, 0.27, 0.00), dark: .systemOrange)
    static let errorText = statusText(light: (0.80, 0.10, 0.10), high: (0.65, 0.05, 0.05), dark: .systemRed)

    private typealias RGB = (r: CGFloat, g: CGFloat, b: CGFloat)

    private static func statusText(light: RGB, high: RGB, dark: UIColor) -> Color {
        Color(UIColor { traits in
            if traits.userInterfaceStyle == .dark { return dark }
            let rgb = traits.accessibilityContrast == .high ? high : light
            return UIColor(red: rgb.r, green: rgb.g, blue: rgb.b, alpha: 1)
        })
    }
}
