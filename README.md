# ControlBar

[![Swift 6.3+](https://img.shields.io/badge/Swift-6.3%2B-F05138?logo=swift&logoColor=white)](https://www.swift.org)
[![iOS 26+](https://img.shields.io/badge/iOS-26%2B-000000?logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![macOS 26+](https://img.shields.io/badge/macOS-26%2B-000000?logo=apple&logoColor=white)](https://developer.apple.com/macos/)
[![visionOS 26+](https://img.shields.io/badge/visionOS-26%2B-000000?logo=apple&logoColor=white)](https://developer.apple.com/visionos/)

A SwiftUI control group that stays accessible at an edge of its container. ControlBar lays out related controls horizontally or vertically, keeps them clear of safe areas, and lets people drag the group between supported edge positions.

## Requirements

- Swift 6.3 or later
- iOS 26, macOS 26, or visionOS 26

## Installation

Add ControlBar to your package dependencies:

```swift
dependencies: [
    .package(
        url: "https://github.com/jnutting/ControlBar",
        branch: "main"
    )
]
```

Then add `ControlBar` to the target that uses it:

```swift
.target(
    name: "MyApp",
    dependencies: ["ControlBar"]
)
```

In Xcode, choose **File → Add Package Dependencies…** and enter:

```
https://github.com/jnutting/ControlBar
```

## Quick start

Place a `ControlBar` in a `ZStack` with the content it controls. Give every `ControlBarItem` a stable identifier; mark buttons and other interactive controls with `isInteractive: true`. Include a non-interactive item, such as the drag-handle image below, so people have a dedicated place to drag the bar.

```swift
import SwiftUI
import ControlBar

struct ReaderView: View {
    var body: some View {
        ZStack {
            DocumentView()

            ControlBar(
                items: [
                    ControlBarItem(id: "dragHandle", isInteractive: false) {
                        Image(systemName: "line.3.horizontal")
                    },
                    ControlBarItem(id: "previous", isInteractive: true) {
                        Button("Previous", systemImage: "chevron.left") {
                            // Show the previous page.
                        }
                    },
                    ControlBarItem(id: "next", isInteractive: true) {
                        Button("Next", systemImage: "chevron.right") {
                            // Show the next page.
                        }
                    }
                ]
            )
            .buttonStyle(.borderedProminent)
        }
    }
}
```

![Reader Control Bar example](Example/reader-control-bar.png)

By default, the bar starts at the leading end of the top edge. People can drag it to another supported edge, and its layout changes orientation automatically.

## Persist the position

Supply a binding when the surrounding view owns the position. This makes it easy to preserve a person's preferred location.

```swift
struct CanvasView: View {
    @State private var controlBarPosition: ControlBar.Position = .bottomEdgeTrailing

    var body: some View {
        ZStack {
            Canvas { _, _ in }

            ControlBar(
                items: [
                    ControlBarItem(id: "dragHandle", isInteractive: false) {
                        Image(systemName: "line.3.horizontal")
                    },
                    ControlBarItem(id: "add", isInteractive: true) {
                        Button("Add", systemImage: "plus") {
                            // Add content.
                        }
                    },
                    ControlBarItem(id: "delete", isInteractive: true) {
                        Button("Delete", systemImage: "trash") {
                            // Delete the selected content.
                        }
                    }
                ],
                position: $controlBarPosition,
                minimumEdgeInsets: EdgeInsets(
                    top: 24,
                    leading: 24,
                    bottom: 24,
                    trailing: 24
                )
            )
            .buttonStyle(.borderedProminent)
            .tint(.indigo)
        }
    }
}
```

![Canvas Control Bar example](Example/canvas-control-bar.png)

Set `draggable: false` when the bar should remain in one location, or provide `itemOrder:` to customize how controls are ordered at each edge.

## License

ControlBar is available under the license in the repository.
