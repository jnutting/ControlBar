//
//  ControlBar+Internals.swift
//  ControlBar
//
//  Created by Jack Nutting on 2026-09-15.
//
import SwiftUI

extension ControlBar {
    func dragGesture(containerSize: CGSize) -> some Gesture {
        DragGesture(coordinateSpace: .named("controlsContainer"))
            .onChanged { gesture in
                if dragStartOrigin == nil, controlSize.width > 0, controlSize.height > 0 {
                    let startOrigin = Self.controlOrigin(
                        for: position,
                        controlSize: controlSize,
                        containerSize: containerSize
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
                    containerSize: containerSize
                )
                let destinationOrigin = Self.controlOrigin(
                    for: newPosition,
                    controlSize: controlSize,
                    containerSize: containerSize
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
        containerSize: CGSize
    ) -> CGPoint {
        let x = position.horizontalLocation == .leading
        ? 0
        : containerSize.width - controlSize.width
        let y = position.verticalLocation == .top
        ? 0
        : containerSize.height - controlSize.height
        return CGPoint(x: x, y: y)
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
