import SwiftUI

/// Wraps children onto new lines like text, used for the word cards.
struct FlowLayout: Layout {
    var spacing: CGFloat = 12

    /// A row that exactly fills the width can overshoot by float rounding and wrap its last item onto an unmeasured line.
    private static let slack: CGFloat = 0.5

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var usedWidth: CGFloat = 0

        for subview in subviews {
            let size = measure(subview, width: maxWidth)
            if x > 0 && x + size.width > maxWidth + Self.slack {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            usedWidth = max(usedWidth, x - spacing)
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: usedWidth, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = measure(subview, width: bounds.width)
            if x > bounds.minX && x + size.width > bounds.maxX + Self.slack {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }

    /// Natural width first, then height at that width so wrapped text counts.
    private func measure(_ subview: LayoutSubview, width: CGFloat) -> CGSize {
        let ideal = subview.sizeThatFits(.unspecified)
        let w = min(ideal.width, width)
        let h = subview.sizeThatFits(ProposedViewSize(width: w, height: nil)).height
        return CGSize(width: w, height: h)
    }
}
