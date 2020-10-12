import Foundation

/*
public class CPUMonitor: BaseMonitor {

    public static let shared = CPUMonitor()
    public var observable = MonitorObservable<Float>(value: 0)

    public func start() {
        timer.fire()
    }

    public func stop() {
        timer.invalidate()
    }

    private lazy var timer = Timer(timeInterval: 0.1, target: MonitorWeakTarget<CPUMonitor>(target: self), selector: #selector(tick), userInfo: nil, repeats: true)

    private override init() {
        super.init()
        RunLoop.main.add(timer, forMode: .common)
    }

    private var cpuUsage: Float {
        var cpuUsageInfo: Float = 0
        var cpuInfo: processor_info_array_t!
        var prevCpuInfo: processor_info_array_t?
        var numCpuInfo: mach_msg_type_number_t = 0
        var numPrevCpuInfo: mach_msg_type_number_t = 0
        var numCPUs: uint = 0
        let CPUUsageLock: NSLock = NSLock()
        var usage:Float32 = 0

        let mibKeys: [Int32] = [CTL_HW, HW_NCPU]
        mibKeys.withUnsafeBufferPointer() { mib in
            var sizeOfNumCPUs: size_t = MemoryLayout<uint>.size
            let status = sysctl(processor_info_array_t(mutating: mib.baseAddress), 2, &numCPUs, &sizeOfNumCPUs, nil, 0)
            if status != 0 {
                numCPUs = 1
            }
        }

        var numCPUsU: natural_t = 0
        let res: kern_return_t = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUsU, &cpuInfo, &numCpuInfo)

        guard res == KERN_SUCCESS else {
            print("get cpu usage error!")
            return cpuUsageInfo
        }

        CPUUsageLock.lock()

        for i in 0 ..< Int32(numCPUs) {
            var inUse: Int32
            var total: Int32
            if let prevCpuInfo = prevCpuInfo {
                inUse = cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_USER)]
                    - prevCpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_USER)]
                    + cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_SYSTEM)]
                    - prevCpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_SYSTEM)]
                    + cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_NICE)]
                    - prevCpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_NICE)]
                total = inUse + (cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_IDLE)]
                    - prevCpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_IDLE)])
            } else {
                inUse = cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_USER)]
                    + cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_SYSTEM)]
                    + cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_NICE)]
                total = inUse + cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_IDLE)]
            }
            let coreInfo = Float(inUse) / Float(total)
            usage += coreInfo
//            print(String(format: "Core: %u Usage: %f", i, Float(inUse) / Float(total)))
        }
//        cpuUsageInfo = String(format:"%.2f",100 * Float(usage) / Float(numCPUs))
        cpuUsageInfo = 100 * Float(usage) / Float(numCPUs)
        CPUUsageLock.unlock()

        if let prevCpuInfo = prevCpuInfo {
            let prevCpuInfoSize: size_t = MemoryLayout<integer_t>.stride * Int(numPrevCpuInfo)
            vm_deallocate(mach_task_self_, vm_address_t(bitPattern: prevCpuInfo), vm_size_t(prevCpuInfoSize))
        }

        prevCpuInfo = cpuInfo
        numPrevCpuInfo = numCpuInfo

        cpuInfo = nil
        numCpuInfo = 0

        return cpuUsageInfo
    }

    @objc private func tick() {
//        mPrint("CPUMonitor: \(cpuUsage)")
//        observable.update(with: cpuUsage)
    }

}
*/
