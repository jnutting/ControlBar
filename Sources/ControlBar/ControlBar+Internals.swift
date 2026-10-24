//
//  ControlBar+Internals.swift
//  ControlBar
//
//  Created by Jack Nutting on 2026-09-15.
//
import SwiftUI

extension ControlBar {
    func dragGesture(
        containerSize: CGSize,
        edgeInsets: EdgeInsets,
        reservedRegionFrames: [CGRect]
    ) -> some Gesture {
        DragGesture(coordinateSpace: .named("controlsContainer"))
            .onChanged { gesture in
                if dragStartOrigin == nil, controlSize.width > 0, controlSize.height > 0 {
                    let startOrigin = Self.controlOrigin(
                        for: position,
                        controlSize: controlSize,
                        containerSize: containerSize,
                        edgeInsets: edgeInsets,
                        reservedRegionFrames: reservedRegionFrames
                    )
                    let localStartLocation = CGPoint(
                        x: gesture.startLocation.x - startOrigin.x,
                        y: gesture.startLocation.y - startOrigin.y
                    )
                    dragStartedInExclusion = dragExclusionFrames.values.contains {
                        $0.contains(localStartLocation)
                    }

                    guard dragStartedInExclusion == false else { return }

                    dragStartOrigin = startOrigin
                    dragAnchor = UnitPoint(
                        x: min(max((gesture.startLocation.x - startOrigin.x) / controlSize.width, 0), 1),
                        y: min(max((gesture.startLocation.y - startOrigin.y) / controlSize.height, 0), 1)
                    )
                    dragStartOrientation = position.orientation
                    dragTransitionStartOrientation = position.orientation
                    dragStartItemOrder = itemOrder(position)
                    dragTargetItemOrder = itemOrder(position)
                }

                guard dragStartedInExclusion == false else { return }
                offset = gesture.translation

                let proposedPosition = Self.newPosition(
                    fingerLocation: gesture.location,
                    oldPosition: position,
                    containerSize: containerSize
                )
                let proposedOrientation = proposedPosition.orientation
                let proposedItemOrder = itemOrder(proposedPosition)
                let currentOrientation = dragOrientation ?? position.orientation
                let currentItemOrder = dragTargetItemOrder ?? itemOrder(position)

                if proposedOrientation != currentOrientation || proposedItemOrder != currentItemOrder {
                    var transaction = Transaction(animation: .smooth(duration: 0.3, extraBounce: 0.2))
                    transaction.disablesAnimations = false
                    withTransaction(transaction) {
                        dragTransitionStartOrientation = currentOrientation
                        dragStartItemOrder = currentItemOrder
                        dragOrientation = proposedOrientation
                        dragTargetItemOrder = proposedItemOrder
                    }
                }

                if proposedPosition != position {
                    setPosition(proposedPosition)
                }
            }
            .onEnded { gesture in
                guard dragStartedInExclusion == false else {
                    dragStartedInExclusion = nil
                    return
                }

                let newPosition = Self.newPosition(
                    fingerLocation: gesture.location,
                    oldPosition: position,
                    containerSize: containerSize
                )
                let currentOrigin = dragStartOrigin ?? Self.controlOrigin(
                    for: position,
                    controlSize: controlSize,
                    containerSize: containerSize,
                    edgeInsets: edgeInsets,
                    reservedRegionFrames: reservedRegionFrames
                )
                let destinationOrigin = Self.controlOrigin(
                    for: newPosition,
                    controlSize: controlSize,
                    containerSize: containerSize,
                    edgeInsets: edgeInsets,
                    reservedRegionFrames: reservedRegionFrames
                )
                let distance = hypot(
                    destinationOrigin.x - currentOrigin.x - gesture.translation.width,
                    destinationOrigin.y - currentOrigin.y - gesture.translation.height
                )
                let duration = min(
                    max(TimeInterval(distance / 800), 0.16),
                    0.45
                )

                withAnimation(.smooth(duration: duration)) {
                    setPosition(newPosition)
                    dragOrientation = nil
                    dragAnchor = nil
                    dragStartOrientation = nil
                    dragTransitionStartOrientation = nil
                    dragStartItemOrder = nil
                    dragTargetItemOrder = nil
                    dragStartOrigin = nil
                    dragStartedInExclusion = nil
                    offset = .zero
                }
            }
    }

    nonisolated static func controlOrigin(
        for position: Position,
        controlSize: CGSize,
        containerSize: CGSize,
        edgeInsets: EdgeInsets,
        reservedRegionFrames: [CGRect]
    ) -> CGPoint {
        let minimumX = edgeInsets.leading
        let maximumX = max(minimumX, containerSize.width - edgeInsets.trailing - controlSize.width)
        let minimumY = edgeInsets.top
        let maximumY = max(minimumY, containerSize.height - edgeInsets.bottom - controlSize.height)
        var origin = CGPoint(
            x: position.horizontalLocation == .leading ? minimumX : maximumX,
            y: position.verticalLocation == .top ? minimumY : maximumY
        )
        let controlFrame = CGRect(origin: origin, size: controlSize)
        let intersectingRegions = reservedRegionFrames.filter(controlFrame.intersects)

        switch position.orientation {
        case .horizontal:
            switch position.horizontalLocation {
            case .leading:
                if let regionEnd = intersectingRegions.map(\.maxX).max() {
                    origin.x = min(max(origin.x, regionEnd), maximumX)
                }
            case .trailing:
                if let regionStart = intersectingRegions.map(\.minX).min() {
                    origin.x = max(min(origin.x, regionStart - controlSize.width), minimumX)
                }
            }
        case .vertical:
            switch position.verticalLocation {
            case .top:
                if let regionEnd = intersectingRegions.map(\.maxY).max() {
                    origin.y = min(max(origin.y, regionEnd), maximumY)
                }
            case .bottom:
                if let regionStart = intersectingRegions.map(\.minY).min() {
                    origin.y = max(min(origin.y, regionStart - controlSize.height), minimumY)
                }
            }
        }

        return origin
    }

    static func reservedRegionFrames(from geometry: GeometryProxy) -> [CGRect] {
#if os(iOS)
        if #available(iOS 27.1, *) {
            geometry.reservedRegions(kind: .occlusion).map(\.frame)
        } else {
            []
        }
#else
        []
#endif
    }

    static func newPosition(
        fingerLocation: CGPoint,
        oldPosition: Position,
        containerSize: CGSize
    ) -> Position {
        let horizontalDistance = fingerLocation.x - containerSize.width / 2
        let verticalDistance = fingerLocation.y - containerSize.height / 2

        // Normalize the axes so the comparison follows the center-to-corner
        // boundaries even when the container isn't square.
        let horizontalMagnitude = abs(horizontalDistance) * containerSize.height
        let verticalMagnitude = abs(verticalDistance) * containerSize.width
        let isLeading = horizontalDistance < 0
        let isTop = verticalDistance < 0

        if horizontalMagnitude > verticalMagnitude {
            if isLeading {
                return isTop ? .leadingEdgeTop : .leadingEdgeBottom
            } else {
                return isTop ? .trailingEdgeTop : .trailingEdgeBottom
            }
        } else if verticalMagnitude > horizontalMagnitude {
            if isTop {
                return isLeading ? .topEdgeLeading : .topEdgeTrailing
            } else {
                return isLeading ? .bottomEdgeLeading : .bottomEdgeTrailing
            }
        } else {
            return oldPosition
        }
    }
}
