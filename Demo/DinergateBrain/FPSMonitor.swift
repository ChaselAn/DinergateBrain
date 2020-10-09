import UIKit

public class FPSMonitor: NSObject {

    public static let shared = FPSMonitor()
    private var observable = MonitorObservable<Int>(value: 60)

    public func start() {
        if link != nil {
            stop()
        }
        link = CADisplayLink(target: MonitorWeakTarget<FPSMonitor>(target: self), selector: #selector(tick))
        link?.add(to: RunLoop.main, forMode: .common)
    }

    public func stop() {
        link?.remove(from: RunLoop.main, forMode: .common)
        link?.invalidate()
        link = nil
    }

    deinit {
        link?.invalidate()
        link = nil
    }

    private var link: CADisplayLink?
    private var lastTimestamp: TimeInterval?

    private override init() {
        super.init()

    }

    @objc private func tick(link: CADisplayLink) {
        guard let lastTimestamp = lastTimestamp else {
            self.lastTimestamp = link.timestamp
            return
        }
        let dif = link.timestamp - lastTimestamp
        guard dif > 0 else { return }
        self.lastTimestamp = link.timestamp
        let fps = Int(1 / dif)
        observable.update(with: fps)
    }
}
