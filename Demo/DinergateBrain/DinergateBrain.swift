import Foundation

final public class DinergateBrain {
    
    public struct Items: OptionSet {
        
        public static let stuck = Items(rawValue: 1 << 0)
        public static let crash = Items(rawValue: 1 << 1)
        public static let fps = Items(rawValue: 1 << 2)
//        static let cpu = Items(rawValue: 1 << 3)
        
        public static let all: Items = [.stuck, .crash, .fps]
        public static let `default`: Items = [.stuck, .crash]
        
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    public static let shared = DinergateBrain()
    
    public func start(items: Items = .default) {
        if items.contains(.stuck) {
            StuckMonitor.shared.start()
        }
        if items.contains(.crash) {
            CrashMonitor.shared.start()
        }
        if items.contains(.fps) {
            FPSMonitor.shared.start()
        }
    }
    
    public func stop() {
        StuckMonitor.shared.stop()
        CrashMonitor.shared.stop()
        FPSMonitor.shared.stop()
    }
}
