import SwiftUI
import ControlBar

struct ContentView: View {
    @State var showsExtraButton = true
    
    var body: some View {
        ZStack {
            previewBackground()
            previewControlBar(extraButton: showsExtraButton)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
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
