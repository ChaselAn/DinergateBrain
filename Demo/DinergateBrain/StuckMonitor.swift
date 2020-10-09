import Foundation

public class StuckMonitor: NSObject {

    public enum StuckType {
        case single // once, blocked for 250ms
        case continuous // five consecutive times, blocked for 50ms * 5
    }

    public static let shared = StuckMonitor()
    public var stuckHappening: ((StuckType) -> Void)?

    public func start() {
        CFRunLoopAddObserver(CFRunLoopGetMain(), observer, CFRunLoopMode.commonModes)
        isStarted = true

        self.timeOutQueue.async { [weak self] in
            guard let self = self else { return }
            while self.isStarted {
                // 单次超过250ms的卡顿，算一次卡顿
                let res = self.singleSemaphore.wait(wallTimeout: .now() + 1)
                switch res {
                case .success:
                    break
                case .timedOut:
                    self.stuckHappening?(.single)
                }
            }
        }

        self.timeOutQueue.async { [weak self] in
            guard let self = self else { return }
            while self.isStarted {
                // 单5次超过50ms的卡顿，也算一次卡顿
                let res = self.fiveSemaphore.wait(timeout: DispatchTime.now() + 0.05)
                switch res {
                case .success:
                    self.timeOutCount = 0
                case .timedOut:
                    self.timeOutCount += 1
                    guard self.timeOutCount >= 5 else {
                        break
                    }
                    self.timeOutCount = 0
                    self.stuckHappening?(.continuous)
                }
            }
        }
    }

    public func stop() {
        isStarted = false
        CFRunLoopRemoveObserver(CFRunLoopGetMain(), observer, CFRunLoopMode.commonModes)
    }

    private var observer: CFRunLoopObserver!

    private var timeOutCount = 0
    private let singleSemaphore = DispatchSemaphore(value: 1)
    private let fiveSemaphore = DispatchSemaphore(value: 1)
    private let timeOutQueue = DispatchQueue(label: "StuckMonitor_timeOutQueue", qos: .userInteractive, attributes: .concurrent)
    private var isStarted = false

    private override init() {
        super.init()

        observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, CFRunLoopActivity.beforeSources.rawValue | CFRunLoopActivity.afterWaiting.rawValue, true, 0) { [weak self] (_, _) in
            guard let self = self else { return }
            self.fiveSemaphore.signal()
            self.singleSemaphore.signal()
        }
        
    }
}
