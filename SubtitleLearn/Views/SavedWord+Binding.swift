import SwiftUI

extension SavedWord {
    /// Binding for the mastery picker that goes through `setLevel`.
    var levelBinding: Binding<Int> {
        Binding(get: { self.level }, set: { self.setLevel($0) })
    }
}
