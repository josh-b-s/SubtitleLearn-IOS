import SwiftUI

extension SavedWord {
    /// Binding for the mastery slider that goes through `setProgress`.
    var progressBinding: Binding<Double> {
        Binding(get: { self.masteryScore }, set: { self.setProgress($0) })
    }
}
