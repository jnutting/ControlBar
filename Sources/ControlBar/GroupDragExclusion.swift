//
//  GroupDragExclusion.swift
//  ControlBar
//
//  Created by Jack Nutting on 2026-09-15.
//

import SwiftUI

extension View {
    func excludesFromGroupDrag(
        _ isExcluded: Bool,
        id: String,
        frames: Binding<[String: CGRect]>
    ) -> some View {
        modifier(
            GroupDragExclusionModifier(
                id: id,
                isExcluded: isExcluded,
                frames: frames
            )
        )
    }
}

private struct GroupDragExclusionModifier: ViewModifier {
    let id: String
    let isExcluded: Bool
    @Binding var frames: [String: CGRect]

    func body(content: Content) -> some View {
        content.onGeometryChange(for: CGRect?.self) { proxy in
            isExcluded ? proxy.frame(in: .named("controlGroup")) : nil
        } action: { frame in
            if let frame {
                frames[id] = frame
            } else {
                frames.removeValue(forKey: id)
            }
        }
    }
}
