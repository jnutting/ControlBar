import SwiftUI

#if DEBUG
private struct ReaderControlBarExample: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.gray.opacity(0.15))

            VStack(alignment: .leading, spacing: 12) {
                Text("A quiet page for reading")
                    .font(.title2.weight(.semibold))

                ForEach(0..<6, id: \.self) { _ in
                    Capsule()
                        .fill(.secondary.opacity(0.18))
                        .frame(height: 10)
                }
            }
            .padding(32)

            ControlBar(
                items: [
                    ControlBarItem(id: "dragHandle", isInteractive: false) {
                        Image(systemName: "line.3.horizontal")
                            .frame(width: 44, height: 44)
                            .accessibilityLabel("Drag control bar")
                    },
                    ControlBarItem(id: "previous", isInteractive: true) {
                        Button {} label: {
                            Image(systemName: "chevron.left")
                        }
                        .accessibilityLabel("Previous")
                    },
                    ControlBarItem(id: "next", isInteractive: true) {
                        Button {} label: {
                            Image(systemName: "chevron.right")
                        }
                        .accessibilityLabel("Next")
                    }
                ],
                position: .trailingEdgeTop
            )
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

private struct CanvasControlBarExample: View {
    @State private var controlBarPosition: ControlBar.Position = .bottomEdgeTrailing

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.indigo.opacity(0.12))

            Canvas { context, size in
                let gridSpacing: CGFloat = 24

                for x in stride(from: 0, through: size.width, by: gridSpacing) {
                    context.stroke(
                        Path(CGRect(x: x, y: 0, width: 0, height: size.height)),
                        with: .color(.indigo.opacity(0.12))
                    )
                }

                for y in stride(from: 0, through: size.height, by: gridSpacing) {
                    context.stroke(
                        Path(CGRect(x: 0, y: y, width: size.width, height: 0)),
                        with: .color(.indigo.opacity(0.12))
                    )
                }
            }
            .padding(12)

            ControlBar(
                items: [
                    ControlBarItem(id: "dragHandle", isInteractive: false) {
                        Image(systemName: "line.3.horizontal")
                            .frame(width: 44, height: 44)
                            .accessibilityLabel("Drag control bar")
                    },
                    ControlBarItem(id: "add", isInteractive: true) {
                        Button {} label: {
                            Image(systemName: "plus")
                        }
                        .accessibilityLabel("Add")
                    },
                    ControlBarItem(id: "delete", isInteractive: true) {
                        Button {} label: {
                            Image(systemName: "trash")
                        }
                        .accessibilityLabel("Delete")
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
        .padding()
    }
}

#Preview("Reader Control Bar") {
    ReaderControlBarExample()
        .frame(width: 460, height: 280)
}

#Preview("Canvas Control Bar") {
    CanvasControlBarExample()
        .frame(width: 460, height: 280)
}
#endif
