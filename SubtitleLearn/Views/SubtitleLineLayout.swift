import SwiftUI

/// Layout flag: this card begins a new subtitle line.
struct LineStartKey: LayoutValueKey {
    static let defaultValue = false
}

/// Flows cards left to right and starts a new row at each subtitle line.
/// Only the last `maxRows` rows are visible, so a full panel scrolls a whole row at a time.
struct SubtitleLineLayout: Layout {
    var spacing: CGFloat = 8
    var maxRows = 2

    private struct Placed {
        let index: Int
        let x: CGFloat
        let size: CGSize
    }

    private struct Row {
        var y: CGFloat
        var height: CGFloat = 0
        var items: [Placed] = []
    }

    private func makeRows(width: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var current = Row(y: 0)
        var x: CGFloat = 0

        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(.unspecified)
            let breaks = subview[LineStartKey.self] || x + size.width > width
            if !current.items.isEmpty && breaks {
                rows.append(current)
                current = Row(y: current.y + current.height + spacing)
                x = 0
            }
            current.items.append(Placed(index: index, x: x, size: size))
            current.height = max(current.height, size.height)
            x += size.width + spacing
        }
        if !current.items.isEmpty { rows.append(current) }
        return rows
    }

    /// Y of the first visible row, so hidden rows sit above the bounds.
    private func offset(_ rows: [Row]) -> CGFloat {
        rows.suffix(maxRows).first?.y ?? 0
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = makeRows(width: proposal.width ?? .infinity, subviews: subviews)
        guard let last = rows.last else { return .zero }
        let width = rows.suffix(maxRows).map { row in row.items.map { $0.x + $0.size.width }.max() ?? 0 }.max() ?? 0
        return CGSize(width: width, height: last.y + last.height - offset(rows))
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = makeRows(width: bounds.width, subviews: subviews)
        let shift = offset(rows)
        for row in rows {
            for item in row.items {
                subviews[item.index].place(
                    at: CGPoint(x: bounds.minX + item.x, y: bounds.minY + row.y - shift),
                    proposal: ProposedViewSize(item.size)
                )
            }
        }
    }
}
