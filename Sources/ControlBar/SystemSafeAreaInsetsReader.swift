//
//  SystemSafeAreaInsetsReader.swift
//  ControlBar
//
//  Created by Jack Nutting on 2026-09-15.
//

import SwiftUI

struct SystemSafeAreaInsetsReader {
    @Binding var insets: EdgeInsets

    func onInsetsChange(_ newInsets: EdgeInsets) -> Void {
        if insets != newInsets {
            insets = newInsets
        }
    }

}

#if canImport(AppKit)
extension SystemSafeAreaInsetsReader: PlatformViewRepresentable {
    func makeNSView(context: Context) -> SafeAreaReportingView {
        SafeAreaReportingView()
    }

    func updateNSView(_ view: SafeAreaReportingView, context: Context) {
        view.onInsetsChange = onInsetsChange
    }
}
#elseif canImport(UIKit)
extension SystemSafeAreaInsetsReader: PlatformViewRepresentable {
    func makeUIView(context: Context) -> SafeAreaReportingView {
        let view = SafeAreaReportingView()
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ view: SafeAreaReportingView, context: Context) {
        view.onInsetsChange = onInsetsChange
    }
}
#else
#error("ControlBar requires UIKit or AppKit.")
#endif

final class SafeAreaReportingView: PlatformView {
    var onInsetsChange: ((EdgeInsets) -> Void)?

#if canImport(AppKit)
    override func hitTest(_ point: NSPoint) -> NSView? {
        nil
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        reportInsets()
    }

    override func layout() {
        super.layout()
        reportInsets()
    }
#elseif canImport(UIKit)
    override func didMoveToWindow() {
        super.didMoveToWindow()
        reportInsets()
    }

    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        reportInsets()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        reportInsets()
    }

#else
#error("ControlBar requires UIKit or AppKit.")
#endif

    private func reportInsets() {
        guard let window else { return }

        let viewFrame = convert(bounds, to: nil)
        onInsetsChange?(window.safeInsets(for: viewFrame))
    }
}
