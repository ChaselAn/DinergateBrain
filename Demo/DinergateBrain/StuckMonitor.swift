import Foundation

public class StuckMonitor: BaseMonitor {
    
    public static let shared = StuckMonitor()
    public var stuckHappening: ((ThreadStackBacktrace) -> Void)?
    public var threshold: TimeInterval = 0.4

    public override func start() {
        super.start()

        if Thread.current.isMainThread {
            StackBacktrace.main_thread_id = mach_thread_self()
        }else {
            DispatchQueue.main.async {
                StackBacktrace.main_thread_id = mach_thread_self()
            }
        }
        
        checkThread = StuckCheckThread()
        checkThread?.start(threshold: threshold, stuckHappening: { [weak self] in
            self?.stuckHappening?(StackBacktrace.value)
        })
    }

    public override func stop() {
        super.stop()
        checkThread?.stop()
    }

    private var checkThread: StuckCheckThread?
    
    deinit {
        checkThread?.cancel()
    }
}

final class StuckCheckThread: Thread {
    
    private var isRunning: Bool {
        get {
            objc_sync_enter(lock)
            let result = _isRunning
            objc_sync_exit(lock)
            return result
        }
        set {
            objc_sync_enter(lock)
            _isRunning = newValue
            objc_sync_exit(lock)
        }
    }
    
    private let lock = NSObject()
    private var _isRunning = false
    private var semaphore = DispatchSemaphore(value: 0)
    private var threshold: TimeInterval = 0.4
    private var stuckHappening: (() -> Void)?
    
    override init() {
        super.init()
        name = "DinergateBrain_StuckCheckThread"
    }
    
    func start(threshold: TimeInterval = 0.4, stuckHappening: (() -> Void)?) {
        self.threshold = threshold
        self.stuckHappening = stuckHappening
        start()
    }
    
    func stop() {
        cancel()
    }

    override func main() {
        while !isCancelled {
            isRunning = true
            DispatchQueue.main.async {
                self.isRunning = false
                self.semaphore.signal()
            }
            Thread.sleep(forTimeInterval: threshold)
            if isRunning {
                stuckHappening?()
            }
            _ = semaphore.wait(timeout: .distantFuture)
        }
    }
}
