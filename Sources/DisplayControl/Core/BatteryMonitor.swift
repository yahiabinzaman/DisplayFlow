import Foundation
import IOKit.ps

public final class BatteryMonitor: ObservableObject {
    public static let shared = BatteryMonitor()
    
    @Published public var isOnBattery: Bool = false
    @Published public var hasBattery: Bool = false
    
    public var onPowerSourceChanged: ((Bool) -> Void)?
    
    private var runLoopSource: CFRunLoopSource?
    
    private init() {
        checkPowerSource()
        setupNotification()
    }
    
    deinit {
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .defaultMode)
        }
    }
    
    private func setupNotification() {
        let context = Unmanaged.passUnretained(self).toOpaque()
        let source = IOPSNotificationCreateRunLoopSource({ context in
            guard let context = context else { return }
            let monitor = Unmanaged<BatteryMonitor>.fromOpaque(context).takeUnretainedValue()
            monitor.checkPowerSource()
        }, context).takeRetainedValue()
        
        self.runLoopSource = source
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .defaultMode)
    }
    
    public func checkPowerSource() {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
              let sources = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef],
              !sources.isEmpty else {
            DispatchQueue.main.async {
                self.hasBattery = false
                self.isOnBattery = false
            }
            return
        }
        
        let powerSourceType = IOPSGetProvidingPowerSourceType(snapshot)?.takeRetainedValue() as String?
        let onBattery = (powerSourceType == kIOPMBatteryPowerKey)
        
        DispatchQueue.main.async {
            self.hasBattery = true
            if self.isOnBattery != onBattery {
                self.isOnBattery = onBattery
                self.onPowerSourceChanged?(onBattery)
            }
        }
    }
}
