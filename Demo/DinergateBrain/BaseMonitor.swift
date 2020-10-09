import Foundation

public class BaseMonitor: NSObject {

    var isStarted: Bool = false
    
    public func start() {
        if isStarted { return }
        isStarted = true
    }
    public func stop() {
        if !isStarted { return }
        isStarted = false
    }
}
