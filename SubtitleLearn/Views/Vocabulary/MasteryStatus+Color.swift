import SwiftUI

extension MasteryStatus {
    var color: Color {
        switch self {
        case .new: .gray
        case .learning: .orange
        case .mastered: .green
        }
    }
}
