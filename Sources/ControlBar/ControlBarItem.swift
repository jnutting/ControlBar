//
//  ControlBarItem.swift
//  ControlBar
//
//  Created by Jack Nutting on 2026-09-15.
//

import SwiftUI

/// A stable description of one control so a control bar can preserve its identity while it moves and reorients.
public struct ControlBarItem: Identifiable {
    /// The stable identity used to preserve the control's view and animation state.
    public let id: String

    /// Whether the control handles its own interaction instead of initiating a bar drag.
    public let isInteractive: Bool
    private let content: @MainActor () -> AnyView

    /// Creates a control-bar item from custom SwiftUI content.
    ///
    /// - Parameters:
    ///   - id: The stable identity for the control.
    ///   - isInteractive: Whether the content should receive interactions without beginning a bar drag.
    ///   - content: A view builder that creates the control's visible content.
    @MainActor
    public init<Content: View>(
        id: String,
        isInteractive: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.id = id
        self.isInteractive = isInteractive
        self.content = { AnyView(content()) }
    }

    @MainActor
    func makeContent() -> AnyView {
        content()
    }
}
