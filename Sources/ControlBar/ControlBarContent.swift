//
//  ControlBarContent.swift
//  ControlBar
//
//  Created by Jack Nutting on 2026-09-15.
//

import SwiftUI

struct ControlBarContent: View {
    let items: [ControlBarItem]
    let spacing: CGFloat
    let orientation: ControlBar.Position.Orientation
    let itemOrder: ControlBar.ItemOrder
    let dragAnchor: UnitPoint?
    let dragStartOrientation: ControlBar.Position.Orientation
    let dragTransitionStartOrientation: ControlBar.Position.Orientation
    let dragStartItemOrder: ControlBar.ItemOrder
    @Binding var dragExclusionFrames: [String: CGRect]
    @Namespace private var namespace

    var body: some View {
        GlassEffectContainer(spacing: spacing) {
            OrientationLayout(
                verticalProgress: orientation == .vertical ? 1 : 0,
                spacing: spacing,
                itemOrder: itemOrder,
                dragAnchor: dragAnchor,
                dragStartItemOrder: dragStartItemOrder,
                dragStartsVertically: dragStartOrientation == .vertical,
                itemTransitionStartsVertically: dragTransitionStartOrientation == .vertical,
                includesBacking: true
            ) {
                controlBacking
                controls
            }
            .padding(4)
            .glassEffectUnion(id: "controls", namespace: namespace)
        }
        .contentShape(Rectangle())
        .coordinateSpace(.named("controlGroup"))
    }

    private var controlBacking: some View {
        Capsule()
            .fill(Platform.controlBackingColor)
            .overlay {
                Capsule()
                    .stroke(Color.primary.opacity(0.16), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.12), radius: 10, y: 2)
            .allowsHitTesting(false)
    }

    @ViewBuilder
    private var controls: some View {
        ForEach(items) { item in
            item.makeContent()
                .controlBarButtonAppearance()
                .glassEffectID(item.id, in: namespace)
                .glassEffectTransition(.matchedGeometry)
                .excludesFromGroupDrag(
                    item.isInteractive,
                    id: item.id,
                    frames: $dragExclusionFrames
                )
        }
    }

}
