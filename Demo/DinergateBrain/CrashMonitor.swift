import Foundation

public class CrashMonitor: BaseMonitor {
    
    public enum CrashType {
        case singal(Int32, String, ThreadStackBacktrace) // singal code, singal name
        case exception(NSException, [String])
    }

    public static let shared = CrashMonitor()
    public var crashHappening: ((CrashType) -> Void)?

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
        
        shared.crashHappening?(.exception(exception, exception.callStackSymbols))
    }
    
    private static let handleSignalException: @convention(c) (Int32) -> Void = { signal in
        guard shared.isStarted else {
            return
        }
        shared.crashHappening?(.singal(signal, name(of: signal), StackBacktrace.value))
        killApp()
    }
    
    private class func name(of signal:Int32) -> String {
        switch (signal) {
        case SIGSEGV:
            return "SIGSEGV"
        case SIGFPE:
            return "SIGFPE"
        case SIGBUS:
            return "SIGBUS"
        case SIGPIPE:
            return "SIGPIPE"
        case SIGHUP:
            return "SIGHUP"
        case SIGINT:
            return "SIGINT"
        case SIGQUIT:
            return "SIGQUIT"
        case SIGABRT:
            return "SIGABRT"
        case SIGILL:
            return "SIGILL"
        case SIGTRAP:
            return "SIGTRAP"
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
