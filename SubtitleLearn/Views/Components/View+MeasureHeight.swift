import SwiftUI

extension View {
    /// Writes the view's laid-out height into `height` whenever it changes.
    func measureHeight(into height: Binding<CGFloat>) -> some View {
        onGeometryChange(for: CGFloat.self) { $0.size.height } action: { height.wrappedValue = $0 }
    }
}
