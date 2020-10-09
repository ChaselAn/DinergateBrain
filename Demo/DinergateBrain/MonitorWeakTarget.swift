import Foundation

final class MonitorWeakTarget<T: NSObject>: NSObject {

    weak var target: T?

    init(target: T) {
        self.target = target
        super.init()
    }

    override func responds(to aSelector: Selector!) -> Bool {
        guard let target = target else {
            return false
        }
        return target.responds(to: aSelector) || super.responds(to: aSelector)
    }

    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return target
    }
}
