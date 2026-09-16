//
//  ControlBar.swift
//  ControlBar
//
//  Created by Jack Nutting on 2026-09-15.
//

import SwiftUI

/// A movable control group that keeps related actions accessible at an edge of its container.
public struct ControlBar: View {
    let positionBinding: Binding<Position>?
    let items: [ControlBarItem]
    let spacing: CGFloat
    let minimumEdgeInsets: EdgeInsets
    let draggable: Bool
    let itemOrder: (Position) -> ItemOrder

    @State var internalPosition: Position
    @State var offset: CGSize = .zero
    @State var dragOrientation: Position.Orientation?
    @State var dragAnchor: UnitPoint?
    @State var dragStartOrientation: Position.Orientation?
    @State var dragTransitionStartOrientation: Position.Orientation?
    @State var dragStartItemOrder: ItemOrder?
    @State var dragTargetItemOrder: ItemOrder?
    @State var dragStartOrigin: CGPoint?
    @State var controlSize: CGSize = .zero
    @State var dragExclusionFrames: [String: CGRect] = [:]
    @State var dragStartedInExclusion: Bool?
    @State var systemSafeAreaInsets = EdgeInsets()

    /// Creates a control bar whose edge position is owned by the caller.
    ///
    /// - Parameters:
    ///   - items: The controls to display in the bar.
    ///   - position: A binding that stores and receives the bar's current edge position.
    ///   - spacing: The distance between adjacent controls.
    ///   - minimumEdgeInsets: The minimum clearance to preserve between the bar and its container edges.
    ///   - draggable: Whether people can drag the bar to a different edge position.
    ///   - itemOrder: A function that determines the visual ordering of controls at each position.
    public init(
        items: [ControlBarItem],
        position: Binding<Position>,
        spacing: CGFloat = 8,
        minimumEdgeInsets: EdgeInsets = EdgeInsets(
            top: 16,
            leading: 16,
            bottom: 16,
            trailing: 16
        ),
        draggable: Bool = true,
        itemOrder: @escaping (Position) -> ItemOrder = { _ in .normal }
    ) {
        self.positionBinding = position
        self.items = items
        self.spacing = spacing
        self.minimumEdgeInsets = minimumEdgeInsets
        self.draggable = draggable
        self.itemOrder = itemOrder
        _internalPosition = State(initialValue: position.wrappedValue)
    }

    /// Creates a control bar that manages its edge position internally.
    ///
    /// - Parameters:
    ///   - items: The controls to display in the bar.
    ///   - position: The bar's initial edge position.
    ///   - spacing: The distance between adjacent controls.
    ///   - minimumEdgeInsets: The minimum clearance to preserve between the bar and its container edges.
    ///   - draggable: Whether people can drag the bar to a different edge position.
    ///   - itemOrder: A function that determines the visual ordering of controls at each position.
    public init(
        items: [ControlBarItem],
        position: Position = .topEdgeLeading,
        spacing: CGFloat = 8,
        minimumEdgeInsets: EdgeInsets = EdgeInsets(
            top: 16,
            leading: 16,
            bottom: 16,
            trailing: 16
        ),
        draggable: Bool = true,
        itemOrder: @escaping (Position) -> ItemOrder = { _ in .normal }
    ) {
        self.positionBinding = nil
        self.items = items
        self.spacing = spacing
        self.minimumEdgeInsets = minimumEdgeInsets
        self.draggable = draggable
        self.itemOrder = itemOrder
        _internalPosition = State(initialValue: position)
    }

    var position: Position {
        positionBinding?.wrappedValue ?? internalPosition
    }

    var layoutItemOrder: ItemOrder {
        dragTargetItemOrder ?? itemOrder(position)
    }

    func setPosition(_ newPosition: Position) {
        if let positionBinding {
            positionBinding.wrappedValue = newPosition
        } else {
            internalPosition = newPosition
        }
    }

    /// The view that lays out the controls, applies safe-area clearance, and handles dragging.
    public var body: some View {
        GeometryReader { geometry in
            ControlBarPlacementLayout(
                position: position,
                offset: offset,
                dragStartOrigin: dragStartOrigin
            ) {
                ControlBarContent(
                    items: items,
                    spacing: spacing,
                    orientation: dragOrientation ?? position.orientation,
                    itemOrder: layoutItemOrder,
                    dragAnchor: dragAnchor,
                    dragStartOrientation: dragStartOrientation ?? position.orientation,
                    dragTransitionStartOrientation: dragTransitionStartOrientation ?? position.orientation,
                    dragStartItemOrder: dragStartItemOrder ?? itemOrder(position),
                    dragExclusionFrames: $dragExclusionFrames
                )
                .onGeometryChange(for: CGSize.self) { proxy in
                    proxy.size
                } action: { newSize in
                    controlSize = newSize
                }
                .dynamicTypeSize(.large)
                .modifier(
                    ConditionalDragGestureModifier(
                        isEnabled: draggable,
                        gesture: dragGesture(containerSize: geometry.size)
                    )
                )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .coordinateSpace(.named("controlsContainer"))
        }
        .padding(systemSafeAreaInsets.max(minimumEdgeInsets))
        .background {
            SystemSafeAreaInsetsReader(insets: $systemSafeAreaInsets)
        }
    }

}

private struct ConditionalDragGestureModifier<Drag: Gesture>: ViewModifier {
    let isEnabled: Bool
    let gesture: Drag

    func body(content: Content) -> some View {
        if isEnabled {
            content.simultaneousGesture(gesture)
        } else {
            content
        }
    }
}

@MainActor @ViewBuilder
private func previewBackground() -> some View {
    Color.cyan

    GeometryReader { geometry in
        Path { path in
            let width = geometry.size.width
            let height = geometry.size.height

            path.move(to: .zero)
            path.addLine(to: CGPoint(x: width, y: height))
            path.move(to: CGPoint(x: width, y: 0))
            path.addLine(to: CGPoint(x: 0, y: height))
            path.move(to: CGPoint(x: width / 2, y: 0))
            path.addLine(to: CGPoint(x: width / 2, y: height))
            path.move(to: CGPoint(x: 0, y: height / 2))
            path.addLine(to: CGPoint(x: width, y: height / 2))
        }
        .stroke(.white.opacity(0.65), lineWidth: 1)
    }
    .allowsHitTesting(false)
}

@MainActor
private func previewControlBar(extraButton: Bool = false) -> some View {
    let itemSize = Platform.itemSize
    let fontSize = Platform.fontSize

    var items = [
        ControlBarItem(id: "scribble", isInteractive: true) {
            Button {

            } label: {
                Image(systemName: "scribble.variable")
                    .font(.system(size: fontSize, weight: .semibold))
                    .frame(width: itemSize, height: itemSize)
            }
        },
        ControlBarItem(id: "close") {
            Text("X")
                .font(.system(size: fontSize, weight: .semibold))
                .frame(width: itemSize, height: itemSize)
        },
        ControlBarItem(id: "eraser", isInteractive: true) {
            Button {

            } label: {
                Image(systemName: "eraser.fill")
                    .font(.system(size: fontSize, weight: .semibold))
                    .frame(width: itemSize, height: itemSize)
            }
        }
    ]
    if extraButton {
        items.append(
            ControlBarItem(id: "compose", isInteractive: true) {
                Button {

                } label: {
                    Image(systemName: "square.and.pencil.circle")
                        .font(.system(size: fontSize, weight: .semibold))
                        .frame(width: itemSize, height: itemSize)
                }
            }
        )
    }
    return ControlBar(items: items)
        .buttonStyle(.plain)
        .tint(.green)
}

@MainActor
private func previewExtraControlToggle(isOn: Binding<Bool>) -> some View {
    Toggle(
        "Toggle extra control",
        isOn: Binding(
            get: { isOn.wrappedValue },
            set: { newValue in
                withAnimation(.smooth) {
                    isOn.wrappedValue = newValue
                }
            }
        )
    )
    .frame(width: 200)
}

#Preview("Full Screen") {
    @Previewable @State var showsExtraButton = true

    ZStack {
        previewBackground()
        previewExtraControlToggle(isOn: $showsExtraButton)
        previewControlBar(extraButton: showsExtraButton)
    }
    .ignoresSafeArea()
}

#Preview("Square") {
    @Previewable @State var showsExtraButton = true

    VStack {
        ZStack {
            previewBackground()
            previewExtraControlToggle(isOn: $showsExtraButton)
            previewControlBar(extraButton: showsExtraButton)
        }
        .frame(width: 400, height: 400)
    }
}
