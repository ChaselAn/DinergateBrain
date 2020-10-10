import Foundation

public class CrashMonitor: BaseMonitor {

    public static let shared = CrashMonitor()
    public var crashHappening: (() -> Void)?

    private var oldAppExceptionHandler : (@convention(c) (NSException) -> Void)?
    
    public override func start() {
        super.start()
        oldAppExceptionHandler = NSGetUncaughtExceptionHandler()
        NSSetUncaughtExceptionHandler(CrashMonitor.handleException)
        
        signal(SIGSEGV, CrashMonitor.handleSignalException)
        signal(SIGFPE, CrashMonitor.handleSignalException)
        signal(SIGBUS, CrashMonitor.handleSignalException)
        signal(SIGPIPE, CrashMonitor.handleSignalException)
        signal(SIGHUP, CrashMonitor.handleSignalException)
        signal(SIGINT, CrashMonitor.handleSignalException)
        signal(SIGQUIT, CrashMonitor.handleSignalException)
        signal(SIGABRT, CrashMonitor.handleSignalException)
        signal(SIGILL, CrashMonitor.handleSignalException)
        signal(SIGTRAP, CrashMonitor.handleSignalException)
    }
    
    public override func stop() {
        super.stop()
        guard let oldAppExceptionHandler = oldAppExceptionHandler else {
            return
        }
        NSSetUncaughtExceptionHandler(oldAppExceptionHandler)
    }
    
    private static let handleException: @convention(c) (NSException) -> Void = {
        (exception) -> Void in
        if let oldAppExceptionHandler = shared.oldAppExceptionHandler {
            oldAppExceptionHandler(exception)
        }
        
        guard shared.isStarted else {
            return
        }
        
        shared.crashHappening?()
//        let callStack = exteption.callStackSymbols.joined(separator: "\r")
//        let reason = exteption.reason ?? ""
//        let name = exteption.name
//        let appinfo = CrashEye.appInfo()
//
//
//        let model = CrashModel(type:CrashModelType.exception,
//                               name:name.rawValue,
//                               reason:reason,
//                               appinfo:appinfo,
//                               callStack:callStack)
//        for delegate in CrashEye.delegates {
//            delegate.delegate?.crashEyeDidCatchCrash(with: model)
//        }
    }
    
    private static let handleSignalException: @convention(c) (Int32) -> Void = { signal in
        guard shared.isStarted else {
            return
        }
        shared.crashHappening?()
        killApp()
    }
    
    private class func name(of signal:Int32) -> String {
        switch (signal) {
        case SIGABRT:
            return "SIGABRT"
        case SIGILL:
            return "SIGILL"
        case SIGSEGV:
            return "SIGSEGV"
        case SIGFPE:
            return "SIGFPE"
        case SIGBUS:
            return "SIGBUS"
        case SIGPIPE:
            return "SIGPIPE"
        default:
            return "OTHER"
        }
    }
    
    private class func killApp(){
        NSSetUncaughtExceptionHandler(nil)
        
        signal(SIGABRT, SIG_DFL)
        signal(SIGILL, SIG_DFL)
        signal(SIGSEGV, SIG_DFL)
        signal(SIGFPE, SIG_DFL)
        signal(SIGBUS, SIG_DFL)
        signal(SIGPIPE, SIG_DFL)
        
        kill(getpid(), SIGKILL)
    }
}
