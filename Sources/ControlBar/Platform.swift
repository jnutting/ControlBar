//
//  Platform.swift
//  ControlBar
//
//  Created by Jack Nutting on 2026-09-15.
//

import SwiftUI

#if canImport(AppKit)
import AppKit

typealias PlatformViewRepresentable = NSViewRepresentable
typealias PlatformView = NSView

extension NSWindow {
    func safeInsets(for viewFrame: CGRect) -> EdgeInsets {
        let safeFrame = contentLayoutRect
        return EdgeInsets(
            top: max(viewFrame.maxY - safeFrame.maxY, 0),
            leading: max(safeFrame.minX - viewFrame.minX, 0),
            bottom: max(safeFrame.minY - viewFrame.minY, 0),
            trailing: max(viewFrame.maxX - safeFrame.maxX, 0)
        )
    }
}

enum Platform {
    static let itemSize: CGFloat = 32
    static let fontSize: CGFloat = 14
    static let controlBackingColor = Color.white.opacity(0.84)
}

struct ControlBarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: 44, minHeight: 44)
            .opacity(configuration.isPressed ? 0.55 : 1)
            .tint(Color.black.opacity(0.78))
            .foregroundStyle(Color.black.opacity(0.78))
            .contentShape(Rectangle())
    }
}

extension View {
    func controlBarButtonAppearance() -> some View {
        self
            .buttonStyle(ControlBarButtonStyle())
            .glassEffect(.clear.interactive())
    }
}

#elseif canImport(UIKit)

import UIKit

typealias PlatformViewRepresentable = UIViewRepresentable
typealias PlatformView = UIView

extension UIWindow {
    func safeInsets(for viewFrame: CGRect) -> EdgeInsets {
        let safeFrame = bounds.inset(by: safeAreaInsets)
        return EdgeInsets(
            top: max(safeFrame.minY - viewFrame.minY, 0),
            leading: max(safeFrame.minX - viewFrame.minX, 0),
            bottom: max(viewFrame.maxY - safeFrame.maxY, 0),
            trailing: max(viewFrame.maxX - safeFrame.maxX, 0)
        )
    }
}

enum Platform {
    static let itemSize: CGFloat = 44
    static let fontSize: CGFloat = 17
    static let controlBackingColor = Color(uiColor: .systemBackground).opacity(0.78)
}

struct ControlBarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.55 : 1)
            .frame(minWidth: 44, minHeight: 44)
            .contentShape(Rectangle())
    }
}

extension View {
    func controlBarButtonAppearance() -> some View {
        self
            .buttonStyle(ControlBarButtonStyle())
            .contentShape(Rectangle())
            .glassEffect(.clear)
    }
}

#else
#error("ControlBar requires UIKit or AppKit.")
#endif
