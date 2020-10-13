import Foundation

public class StuckMonitor: BaseMonitor {

    public class Threshold {
        /// 单次超过250ms的卡顿，算一次卡顿
        public var singleTimeout: TimeInterval = 0.25
        /// 连续5次，每次超过50ms的卡顿，也算一次卡顿。 nil为不监测连续卡顿
        public var continuousThreshold: (time: Int, timeout: TimeInterval)? = (time: 5, timeout: 0.05)
        
        public init() {}
    }
    
    public enum StuckType {
        case single // 单词超过阈值的卡顿
        case continuous // 连续的卡顿
    }

    public static let shared = StuckMonitor()
    public var stuckHappening: ((StuckType) -> Void)?
    public var threshold: Threshold = Threshold()

    public override func start() {
        super.start()
        CFRunLoopAddObserver(CFRunLoopGetMain(), observer, CFRunLoopMode.commonModes)

        let singleTimeout = self.threshold.singleTimeout
        self.timeOutQueue.async { [weak self] in
            guard let self = self else { return }
            while self.isStarted {
                let res = self.singleSemaphore.wait(wallTimeout: .now() + singleTimeout)
                switch res {
                case .success:
                    break
                case .timedOut:
                    self.stuckHappening?(.single)
                }
            }
        }

        if let continuousThreshold = threshold.continuousThreshold {
            self.timeOutQueue.async { [weak self] in
                guard let self = self else { return }
                while self.isStarted {
                    let res = self.fiveSemaphore.wait(timeout: DispatchTime.now() + continuousThreshold.timeout)
                    switch res {
                    case .success:
                        self.timeOutCount = 0
                    case .timedOut:
                        self.timeOutCount += 1
                        guard self.timeOutCount >= continuousThreshold.time else {
                            break
                        }
                        self.timeOutCount = 0
                        self.stuckHappening?(.continuous)
                    }
                }
            }
        }
    }

    public override func stop() {
        super.stop()
        CFRunLoopRemoveObserver(CFRunLoopGetMain(), observer, CFRunLoopMode.commonModes)
    }

    private var observer: CFRunLoopObserver!

    private var timeOutCount = 0
    private let singleSemaphore = DispatchSemaphore(value: 1)
    private let fiveSemaphore = DispatchSemaphore(value: 1)
    private let timeOutQueue = DispatchQueue(label: "StuckMonitor_timeOutQueue", qos: .userInteractive, attributes: .concurrent)

    private override init() {
        super.init()

        observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, CFRunLoopActivity.beforeSources.rawValue | CFRunLoopActivity.afterWaiting.rawValue, true, 0) { [weak self] (_, _) in
            guard let self = self else { return }
            self.fiveSemaphore.signal()
            self.singleSemaphore.signal()
        }
    }
}
