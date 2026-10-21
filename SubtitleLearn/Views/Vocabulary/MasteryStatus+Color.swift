import SwiftUI

extension MasteryStatus {
    /// A different shape per status, so the list never relies on colour alone.
    var symbol: String {
        switch self {
        case .new: "circle"
        case .learning: "circle.lefthalf.filled"
        case .mastered: "checkmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .new: .gray
        case .learning: .orange
        case .mastered: .green
        }
    }
}
