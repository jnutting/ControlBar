//
//  OrientationLayout.swift
//  ControlBar
//
//  Created by Jack Nutting on 2026-09-15.
//

import SwiftUI

struct OrientationLayout: Layout {
    var verticalProgress: CGFloat
    let spacing: CGFloat
    let itemOrder: ControlBar.ItemOrder
    let dragAnchor: UnitPoint?
    let dragStartItemOrder: ControlBar.ItemOrder
    let dragStartsVertically: Bool
    let itemTransitionStartsVertically: Bool
    let includesBacking: Bool

    init(
        verticalProgress: CGFloat,
        spacing: CGFloat,
        itemOrder: ControlBar.ItemOrder,
        dragAnchor: UnitPoint?,
        dragStartItemOrder: ControlBar.ItemOrder,
        dragStartsVertically: Bool,
        itemTransitionStartsVertically: Bool,
        includesBacking: Bool = false
    ) {
        self.verticalProgress = verticalProgress
        self.spacing = spacing
        self.itemOrder = itemOrder
        self.dragAnchor = dragAnchor
        self.dragStartItemOrder = dragStartItemOrder
        self.dragStartsVertically = dragStartsVertically
        self.itemTransitionStartsVertically = itemTransitionStartsVertically
        self.includesBacking = includesBacking
    }

    var animatableData: CGFloat {
        get { verticalProgress }
        set { verticalProgress = newValue }
    }

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        metrics(for: subviews).layoutSize
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let metrics = metrics(for: subviews)
        let origin = CGPoint(
            x: bounds.midX - metrics.layoutSize.width / 2,
            y: bounds.midY - metrics.layoutSize.height / 2
        )

        if includesBacking, let backing = subviews.first {
            backing.place(
                at: CGPoint(
                    x: origin.x + metrics.controlBounds.minX,
                    y: origin.y + metrics.controlBounds.minY
                ),
                anchor: .topLeading,
                proposal: ProposedViewSize(metrics.controlBounds.size)
            )
        }

        for (subview, frame) in zip(controlSubviews(in: subviews), metrics.controlFrames) {
            subview.place(
                at: CGPoint(
                    x: origin.x + frame.minX,
                    y: origin.y + frame.minY
                ),
                anchor: .topLeading,
                proposal: .unspecified
            )
        }
    }

    private func metrics(for subviews: Subviews) -> LayoutMetrics {
        let controlSubviews = controlSubviews(in: subviews)
        let sizes = controlSubviews.map { $0.sizeThatFits(.unspecified) }

        guard !sizes.isEmpty else {
            return LayoutMetrics(layoutSize: .zero, controlBounds: .zero, controlFrames: [])
        }

        let horizontalHeight = sizes.map(\.height).max() ?? 0
        let verticalWidth = sizes.map(\.width).max() ?? 0
        let horizontalWidth = sizes.reduce(0) { $0 + $1.width }
        + spacing * CGFloat(max(sizes.count - 1, 0))
        let verticalHeight = sizes.reduce(0) { $0 + $1.height }
        + spacing * CGFloat(max(sizes.count - 1, 0))
        let horizontalSize = CGSize(width: horizontalWidth, height: horizontalHeight)
        let verticalSize = CGSize(width: verticalWidth, height: verticalHeight)
        let layoutSize = CGSize(
            width: horizontalSize.width + (verticalSize.width - horizontalSize.width) * verticalProgress,
            height: horizontalSize.height + (verticalSize.height - horizontalSize.height) * verticalProgress
        )
        let arrangementOrigins = arrangementOrigins(
            horizontalSize: horizontalSize,
            verticalSize: verticalSize
        )

        // Liquid Glass treats the shape identity and the layout geometry as a
        // coupled animation. If a drag crosses from horizontal to vertical and
        // then back again, reusing the gesture's original orientation for every
        // crossing makes one direction animate correctly and the other appear to
        // swap items before sliding them into place. Updating the original
        // drag-start orientation would fix that ordering path, but it also changes
        // the anchor math and shifts the whole control group. Keep those concerns
        // separate: the transition-start orientation is allowed to refresh at each
        // threshold crossing, while the drag-start orientation remains fixed for
        // positioning. Revisit this split if future Liquid Glass releases make
        // bidirectional orientation changes preserve stable item geometry without
        // this extra source/target bookkeeping.
        let horizontalOrder = itemTransitionStartsVertically ? itemOrder : dragStartItemOrder
        let verticalOrder = itemTransitionStartsVertically ? dragStartItemOrder : itemOrder
        let horizontalOffsets = horizontalOffsets(for: sizes, order: horizontalOrder)
        let verticalOffsets = verticalOffsets(for: sizes, order: verticalOrder)

        var frames: [CGRect] = []

        for (index, size) in sizes.enumerated() {
            let horizontalPoint = CGPoint(
                x: horizontalOffsets[index],
                y: (horizontalHeight - size.height) / 2
            )
            let verticalPoint = CGPoint(
                x: (verticalWidth - size.width) / 2,
                y: verticalOffsets[index]
            )
            let point = CGPoint(
                x: horizontalPoint.x + arrangementOrigins.horizontal.x
                + (verticalPoint.x + arrangementOrigins.vertical.x
                   - horizontalPoint.x - arrangementOrigins.horizontal.x) * verticalProgress,
                y: horizontalPoint.y + arrangementOrigins.horizontal.y
                + (verticalPoint.y + arrangementOrigins.vertical.y
                   - horizontalPoint.y - arrangementOrigins.horizontal.y) * verticalProgress
            )

            frames.append(CGRect(origin: point, size: size))
        }

        let controlBounds = frames.dropFirst().reduce(frames[0]) { partialResult, frame in
            partialResult.union(frame)
        }
        return LayoutMetrics(
            layoutSize: layoutSize,
            controlBounds: controlBounds,
            controlFrames: frames
        )
    }

    private func horizontalOffsets(
        for sizes: [CGSize],
        order: ControlBar.ItemOrder
    ) -> [CGFloat] {
        offsets(for: sizes.map(\.width), order: order)
    }

    private func verticalOffsets(
        for sizes: [CGSize],
        order: ControlBar.ItemOrder
    ) -> [CGFloat] {
        offsets(for: sizes.map(\.height), order: order)
    }

    private func offsets(
        for lengths: [CGFloat],
        order: ControlBar.ItemOrder
    ) -> [CGFloat] {
        let totalLength = lengths.reduce(0, +)
        + spacing * CGFloat(max(lengths.count - 1, 0))
        var leadingOffset: CGFloat = 0
        var trailingOffset = totalLength
        var offsets: [CGFloat] = []

        for length in lengths {
            switch order {
            case .normal:
                offsets.append(leadingOffset)
                leadingOffset += length + spacing
            case .reversed:
                trailingOffset -= length
                offsets.append(trailingOffset)
                trailingOffset -= spacing
            }
        }

        return offsets
    }

    private func controlSubviews(in subviews: Subviews) -> Subviews.SubSequence {
        includesBacking ? subviews.dropFirst() : subviews[...]
    }

    private func arrangementOrigins(
        horizontalSize: CGSize,
        verticalSize: CGSize
    ) -> (horizontal: CGPoint, vertical: CGPoint) {
        guard let dragAnchor else {
            return (.zero, .zero)
        }

        let horizontalAnchor = CGPoint(
            x: horizontalSize.width * dragAnchor.x,
            y: horizontalSize.height * dragAnchor.y
        )
        let verticalAnchor = CGPoint(
            x: verticalSize.width * dragAnchor.x,
            y: verticalSize.height * dragAnchor.y
        )

        if !dragStartsVertically {
            return (
                .zero,
                CGPoint(
                    x: horizontalAnchor.x - verticalAnchor.x,
                    y: horizontalAnchor.y - verticalAnchor.y
                )
            )
        } else {
            return (
                CGPoint(
                    x: verticalAnchor.x - horizontalAnchor.x,
                    y: verticalAnchor.y - horizontalAnchor.y
                ),
                .zero
            )
        }
    }
}

private struct LayoutMetrics {
    let layoutSize: CGSize
    let controlBounds: CGRect
    let controlFrames: [CGRect]
}
