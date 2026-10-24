import CoreGraphics
import SwiftUI
import Testing
@testable import ControlBar

@Suite("Control bar placement")
struct ControlBarPlacementTests {
    private let containerSize = CGSize(width: 390, height: 844)
    private let controlSize = CGSize(width: 100, height: 44)

    @Test
    func safeAreaInsetsDetermineTheNormalOrigin() {
        let origin = ControlBar.controlOrigin(
            for: .topEdgeLeading,
            controlSize: controlSize,
            containerSize: containerSize,
            edgeInsets: EdgeInsets(top: 59, leading: 16, bottom: 34, trailing: 16),
            reservedRegionFrames: []
        )

        #expect(origin == CGPoint(x: 16, y: 59))
    }

    @Test
    func leadingHorizontalBarMovesPastAnIntersectingCornerRegion() {
        let origin = ControlBar.controlOrigin(
            for: .topEdgeLeading,
            controlSize: controlSize,
            containerSize: containerSize,
            edgeInsets: EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
            reservedRegionFrames: [CGRect(x: 0, y: 0, width: 38, height: 40)]
        )

        #expect(origin == CGPoint(x: 38, y: 16))
    }

    @Test
    func trailingVerticalBarMovesPastAnIntersectingCornerRegion() {
        let origin = ControlBar.controlOrigin(
            for: .trailingEdgeBottom,
            controlSize: CGSize(width: 44, height: 100),
            containerSize: containerSize,
            edgeInsets: EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
            reservedRegionFrames: [CGRect(x: 352, y: 804, width: 38, height: 40)]
        )

        #expect(origin == CGPoint(x: 330, y: 704))
    }

    @Test
    func nonintersectingReservedRegionDoesNotMoveTheBar() {
        let origin = ControlBar.controlOrigin(
            for: .topEdgeLeading,
            controlSize: controlSize,
            containerSize: containerSize,
            edgeInsets: EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
            reservedRegionFrames: [CGRect(x: 352, y: 0, width: 38, height: 40)]
        )

        #expect(origin == CGPoint(x: 16, y: 16))
    }
}
