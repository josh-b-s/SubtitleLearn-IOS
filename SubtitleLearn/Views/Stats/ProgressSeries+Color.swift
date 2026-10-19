import SwiftUI

extension ProgressSeries {
    var color: Color {
        switch self {
        case .learned: .blue
        case .saved: .orange
        case .mastered: .green
        }
    }
}
