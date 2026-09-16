//
//  ControlBarPlacementLayout.swift
//  ControlBar
//
//  Created by Jack Nutting on 2026-09-15.
//

import SwiftUI

struct ControlBarPlacementLayout: Layout {
    let position: ControlBar.Position
    let offset: CGSize
    let dragStartOrigin: CGPoint?

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        guard let subview = subviews.first else { return }

        let controlSize = subview.sizeThatFits(.unspecified)
        let origin = dragStartOrigin ?? ControlBar.controlOrigin(
            for: position,
            controlSize: controlSize,
            containerSize: bounds.size
        )

        subview.place(
            at: CGPoint(
                x: bounds.minX + origin.x + offset.width,
                y: bounds.minY + origin.y + offset.height
            ),
            anchor: .topLeading,
            proposal: .unspecified
        )
    }
}
