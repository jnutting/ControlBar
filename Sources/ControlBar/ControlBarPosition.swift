//
//  ControlBarPosition.swift
//  ControlBar
//
//  Created by Jack Nutting on 2026-09-15.
//

extension ControlBar {
    /// The ordering options a control bar uses to keep controls readable as its edge changes.
    public enum ItemOrder: Sendable {
        /// Places controls from the leading/top edge toward the trailing/bottom edge.
        case normal

        /// Places controls from the trailing/bottm edge toward the leading/top edge.
        case reversed
    }

    /// The supported container-edge locations that let a control bar remain within easy reach.
    public enum Position: String, CaseIterable, Sendable {
        enum HorizontalLocation {
            case leading
            case trailing
        }

        enum VerticalLocation {
            case top
            case bottom
        }

        /// The axis along which the bar lays out its controls at a position.
        public enum Orientation: Sendable {
            /// Arranges controls from leading to trailing.
            case horizontal

            /// Arranges controls from top to bottom.
            case vertical
        }

        /// The leading end of the top edge.
        case topEdgeLeading

        /// The trailing end of the top edge.
        case topEdgeTrailing

        /// The leading end of the bottom edge.
        case bottomEdgeLeading

        /// The trailing end of the bottom edge.
        case bottomEdgeTrailing

        /// The bottom end of the leading edge.
        case leadingEdgeBottom

        /// The top end of the leading edge.
        case leadingEdgeTop

        /// The bottom end of the trailing edge.
        case trailingEdgeBottom

        /// The top end of the trailing edge.
        case trailingEdgeTop

        var horizontalLocation: HorizontalLocation {
            switch self {
            case .topEdgeLeading, .bottomEdgeLeading, .leadingEdgeBottom, .leadingEdgeTop:
                return .leading
            case .topEdgeTrailing, .bottomEdgeTrailing, .trailingEdgeBottom, .trailingEdgeTop:
                return .trailing
            }
        }

        var verticalLocation: VerticalLocation {
            switch self {
            case .topEdgeLeading, .topEdgeTrailing, .leadingEdgeTop, .trailingEdgeTop:
                return .top
            case .bottomEdgeLeading, .bottomEdgeTrailing, .leadingEdgeBottom, .trailingEdgeBottom:
                return .bottom
            }
        }

        /// The layout axis associated with this edge position.
        public var orientation: Orientation {
            switch self {
            case .topEdgeLeading, .topEdgeTrailing, .bottomEdgeLeading, .bottomEdgeTrailing:
                return .horizontal
            case .leadingEdgeTop, .leadingEdgeBottom, .trailingEdgeTop, .trailingEdgeBottom:
                return .vertical
            }
        }
    }

    /// Creates an item-ordering function from position-specific overrides.
    ///
    /// Use this helper when only selected positions require a different order.
    ///
    /// - Parameters:
    ///   - itemOrderByPosition: The ordering overrides keyed by edge position.
    ///   - defaultOrder: The ordering to use for positions without an override.
    /// - Returns: A function that supplies the appropriate ordering for a position.
    public nonisolated static func itemOrder(
        _ itemOrderByPosition: [Position: ItemOrder],
        default defaultOrder: ItemOrder = .normal
    ) -> (Position) -> ItemOrder {
        { position in
            itemOrderByPosition[position] ?? defaultOrder
        }
    }
}
