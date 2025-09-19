import Foundation

/// Placeholder timeline engine responsible for converting gesture input to temporal scale.
final class TimeScaleEngine {
    struct State {
        var unitsPerPoint: Double
    }

    private(set) var state: State

    init(initialState: State = State(unitsPerPoint: 1.0)) {
        state = initialState
    }

    func update(unitsPerPoint: Double) {
        state.unitsPerPoint = unitsPerPoint
    }
}

/// Placeholder display link wrapper; real implementation will bind to CADisplayLink later.
final class TimelineClock {
    private(set) var isRunning = false

    func start() {
        isRunning = true
    }

    func stop() {
        isRunning = false
    }
}
