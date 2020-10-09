import Foundation

final class MonitorObservable<Value> {
    private var value: Value
    private var observations = [UUID: (Value) -> Void]()

    init(value: Value) {
        self.value = value
    }

    func update(with value: Value) {
        self.value = value

        for observation in observations.values {
            observation(value)
        }
    }

    func addObserver<O: AnyObject>(_ observer: O,
                                          using closure: @escaping (O, Value) -> Void) {
        let id = UUID()

        observations[id] = { [weak self, weak observer] value in
            // If the observer has been deallocated, we can safely remove
            // the observation.
            guard let observer = observer else {
                self?.observations[id] = nil
                return
            }

            closure(observer, value)
        }

        // Directly call the observation closure with the
        // current value.
        closure(observer, value)
    }
}
