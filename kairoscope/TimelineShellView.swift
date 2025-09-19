import SwiftUI

struct TimelineShellView: View {
    @StateObject private var viewModel = TimelineViewModel()

    private let backgroundColor = Color.black
    private let accentColor = Color(red: 1.0, green: 0.84, blue: 0.0)

    var body: some View {
        GeometryReader { proxy in
            let anchorSize = min(proxy.size.width, proxy.size.height) * 0.08
            let safeTop = proxy.safeAreaInsets.top

            ZStack {
                backgroundColor
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    title
                        .padding(.top, safeTop + 24)
                        .padding(.bottom, 32)

                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .top)

                VStack {
                    Spacer()

                    TimelinePlaceholderView(
                        snapshot: viewModel.snapshot,
                        anchorDiameter: anchorSize
                    )
                    .frame(height: max(anchorSize * 2.8, 200))
                    .padding(.horizontal, 24)

                    Spacer()
                }
            }
            .onAppear { viewModel.start() }
            .onDisappear { viewModel.stop() }
        }
    }

    private var title: some View {
        Text("Kairoscope")
            .font(.system(size: 28, weight: .semibold, design: .default))
            .kerning(2)
            .textCase(.uppercase)
            .foregroundStyle(accentColor)
            .accessibilityAddTraits(.isHeader)
    }
}

private struct TimelinePlaceholderView: View {
    private let accentColor = Color(red: 1.0, green: 0.84, blue: 0.0)
    let snapshot: TimelineSnapshot
    let anchorDiameter: CGFloat

    var body: some View {
        TimelineTicksPlaceholder(
            ticks: snapshot.tickMarks,
            anchorDiameter: anchorDiameter,
            accentColor: accentColor
        )
        .frame(maxWidth: .infinity)
    }
}

private struct TimelineTicksPlaceholder: View {
    let ticks: [TimelineTick]
    let anchorDiameter: CGFloat
    let accentColor: Color

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let centerX = size.width / 2
            let baselineY = size.height * 0.5
            let presentOffset = ticks.first(where: { abs($0.position) < 0.1 })?.position ?? 0
            let presentX = centerX + presentOffset

            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: -size.width, y: baselineY))
                    path.addLine(to: CGPoint(x: size.width * 2, y: baselineY))
                }
                .stroke(Color.white.opacity(0.18), lineWidth: 2)

                Path { path in
                    path.move(to: CGPoint(x: -size.width, y: baselineY))
                    path.addLine(to: CGPoint(x: min(presentX, size.width * 2), y: baselineY))
                }
                .stroke(accentColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))

                ForEach(ticks) { tick in
                    let x = centerX + tick.position
                    let tickHeight: CGFloat = tick.kind == .major ? 36 : 20
                    let lineColor = tick.kind == .major ? accentColor : Color.white.opacity(0.35)
                    let lineWidth: CGFloat = tick.kind == .major ? 2 : 1

                    Path { path in
                        path.move(to: CGPoint(x: x, y: baselineY - tickHeight / 2))
                        path.addLine(to: CGPoint(x: x, y: baselineY + tickHeight / 2))
                    }
                    .stroke(lineColor, lineWidth: lineWidth)

                    if let label = tick.label {
                        Text(label)
                            .font(.caption2)
                            .foregroundStyle(accentColor)
                            .fixedSize()
                            .position(x: x, y: baselineY - tickHeight / 2 - 12)
                    }
                }

                Circle()
                    .strokeBorder(accentColor, lineWidth: 3)
                    .background(
                        Circle()
                            .fill(Color.black)
                    )
                    .frame(width: anchorDiameter, height: anchorDiameter)
                    .position(x: presentX, y: baselineY)
                    .accessibilityLabel("Present moment anchor")
            }
        }
        .frame(height: max(anchorDiameter * 2.4, 160))
    }
}
