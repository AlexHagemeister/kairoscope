import SwiftUI
import Combine

/// Snapshot consumed by `TimelineShellView` for rendering.
struct TimelineSnapshot {
    let centerTime: Date
    let tickMarks: [TimelineTick]

    static let placeholder = TimelineSnapshot(
        centerTime: Date(),
        tickMarks: TimelineTick.placeholderSet
    )
}

struct TimelineTick: Identifiable {
    enum Kind {
        case major
        case minor
    }

    let id = UUID()
    let kind: Kind
    let label: String?
    let position: CGFloat

    static let placeholderSet: [TimelineTick] = stride(from: -12, through: 12, by: 1).map { index in
        let isMajor = index.isMultiple(of: 2)
        let label: String?

        if index == 0 {
            label = nil
        } else if isMajor {
            label = "\(abs(index))s"
        } else {
            label = nil
        }

        return TimelineTick(
            kind: isMajor ? .major : .minor,
            label: label,
            position: CGFloat(index) * 32
        )
    }
}

/// View model responsible for coordinating timeline state.
@MainActor
final class TimelineViewModel: ObservableObject {
    @Published private(set) var snapshot: TimelineSnapshot

    private var clock: TimelineClock
    private var timeScaleEngine: TimeScaleEngine
    private var cancellables: Set<AnyCancellable> = []

    init(clock: TimelineClock, timeScaleEngine: TimeScaleEngine) {
        self.clock = clock
        self.timeScaleEngine = timeScaleEngine
        self.snapshot = .placeholder
    }

    convenience init() {
        self.init(clock: TimelineClock(), timeScaleEngine: TimeScaleEngine())
    }

    func start() {
        clock.start()
        // Placeholder logic: emit static snapshot initially.
        snapshot = .placeholder
    }

    func stop() {
        clock.stop()
    }
}
