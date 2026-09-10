import Foundation
import CoreGraphics
import AppKit
import Combine

public final class DisplayManager: ObservableObject {
    public static let shared = DisplayManager()
    
    @Published public var displays: [DisplayModel] = []
    @Published public var selectedPreset: String? = nil
    @Published public var autoBatteryEcoEnabled: Bool {
        didSet {
            UserDefaults.standard.set(autoBatteryEcoEnabled, forKey: "autoBatteryEcoEnabled")
        }
    }
    
    private var brightnessMemory: [CGDirectDisplayID: Float] = [:]
    private var warmthMemory: [CGDirectDisplayID: Float] = [:]
    private var blackoutMemory: [CGDirectDisplayID: Bool] = [:]
    
    private init() {
        self.autoBatteryEcoEnabled = UserDefaults.standard.bool(forKey: "autoBatteryEcoEnabled")
        refreshDisplays()
        setupListeners()
        setupBatteryObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupListeners() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleScreenChange),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
        
        CGDisplayRegisterReconfigurationCallback({ (displayID, flags, userInfo) in
            guard let userInfo = userInfo else { return }
            let manager = Unmanaged<DisplayManager>.fromOpaque(userInfo).takeUnretainedValue()
            DispatchQueue.main.async {
                manager.refreshDisplays()
            }
        }, Unmanaged.passUnretained(self).toOpaque())
    }
    
    private func setupBatteryObserver() {
        BatteryMonitor.shared.onPowerSourceChanged = { [weak self] onBattery in
            guard let self = self, self.autoBatteryEcoEnabled else { return }
            if onBattery {
                self.applyEcoMode()
            } else {
                self.applyProMotionMode()
            }
        }
    }
    
    @objc private func handleScreenChange() {
        DispatchQueue.main.async { [weak self] in
            self?.refreshDisplays()
        }
    }
    
    public func refreshDisplays() {
        var count: UInt32 = 0
        var activeIDs = [CGDirectDisplayID](repeating: 0, count: 16)
        CGGetActiveDisplayList(16, &activeIDs, &count)
        
        var updatedDisplays: [DisplayModel] = []
        
        for i in 0..<Int(count) {
            let dID = activeIDs[i]
            let isBuiltin = CGDisplayIsBuiltin(dID) != 0
            let isMain = CGDisplayIsMain(dID) != 0
            
            // Resolve Display Name
            var name = isBuiltin ? "Built-in Display" : (isMain ? "Main Display" : "External Display \(i + 1)")
            for screen in NSScreen.screens {
                if let num = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID, num == dID {
                    name = screen.localizedName
                    break
                }
            }
            
            guard let currentMode = CGDisplayCopyDisplayMode(dID) else { continue }
            let pWidth = currentMode.pixelWidth
            let pHeight = currentMode.pixelHeight
            let lWidth = currentMode.width
            let lHeight = currentMode.height
            let currentHz = currentMode.refreshRate > 0 ? currentMode.refreshRate : 60.0
            
            // Collect all unique available refresh rates & resolutions
            let options = [kCGDisplayShowDuplicateLowResolutionModes: kCFBooleanTrue] as CFDictionary
            var ratesSet = Set<Double>()
            var resolutionsDict: [String: DisplayResolution] = [:]
            
            if let modeList = CGDisplayCopyAllDisplayModes(dID, options) as? [CGDisplayMode] {
                for mode in modeList {
                    // Refresh rates for current resolution
                    if mode.pixelWidth == pWidth && mode.pixelHeight == pHeight {
                        if mode.refreshRate > 0 {
                            ratesSet.insert(mode.refreshRate)
                        }
                    }
                    
                    // Resolutions
                    let isHiDPI = (mode.pixelWidth > mode.width && mode.width > 0)
                    let resKey = "\(mode.width)x\(mode.height)_\(mode.pixelWidth)x\(mode.pixelHeight)"
                    if resolutionsDict[resKey] == nil {
                        resolutionsDict[resKey] = DisplayResolution(
                            width: mode.width,
                            height: mode.height,
                            pixelWidth: mode.pixelWidth,
                            pixelHeight: mode.pixelHeight,
                            isHiDPI: isHiDPI
                        )
                    }
                }
            }
            
            if ratesSet.isEmpty {
                ratesSet.insert(currentHz)
            }
            let sortedRates = ratesSet.sorted()
            let sortedResolutions = Array(resolutionsDict.values).sorted {
                if $0.pixelWidth != $1.pixelWidth {
                    return $0.pixelWidth > $1.pixelWidth
                }
                return $0.width > $1.width
            }
            
            // Brightness check
            var supportsHardware = false
            var currentBrightness: Float = brightnessMemory[dID] ?? 1.0
            
            if let hwBrightness = DisplayBrightnessBridge.shared.getHardwareBrightness(displayID: dID) {
                supportsHardware = true
                currentBrightness = hwBrightness
            }
            
            let currentWarmth = warmthMemory[dID] ?? 0.0
            let isBlackout = blackoutMemory[dID] ?? false
            
            let model = DisplayModel(
                id: dID,
                name: name,
                isBuiltin: isBuiltin,
                isMain: isMain,
                width: lWidth,
                height: lHeight,
                pixelWidth: pWidth,
                pixelHeight: pHeight,
                currentRefreshRate: currentHz,
                availableRefreshRates: sortedRates,
                availableResolutions: sortedResolutions,
                brightness: currentBrightness,
                warmth: currentWarmth,
                isBlackedOut: isBlackout,
                supportsHardwareBrightness: supportsHardware
            )
            
            updatedDisplays.append(model)
        }
        
        self.displays = updatedDisplays
    }
    
    public func setRefreshRate(for display: DisplayModel, rate: Double) {
        let options = [kCGDisplayShowDuplicateLowResolutionModes: kCFBooleanTrue] as CFDictionary
        guard let modeList = CGDisplayCopyAllDisplayModes(display.id, options) as? [CGDisplayMode] else { return }
        
        let candidates = modeList.filter {
            $0.pixelWidth == display.pixelWidth &&
            $0.pixelHeight == display.pixelHeight &&
            abs($0.refreshRate - rate) < 0.1
        }
        
        let targetMode = candidates.first(where: { $0.width == display.width && $0.height == display.height }) ?? candidates.first
        
        if let mode = targetMode {
            let result = CGDisplaySetDisplayMode(display.id, mode, nil)
            if result == .success {
                if let index = displays.firstIndex(where: { $0.id == display.id }) {
                    displays[index].currentRefreshRate = rate
                }
            }
        }
    }
    
    public func setResolution(for display: DisplayModel, resolution: DisplayResolution) {
        let options = [kCGDisplayShowDuplicateLowResolutionModes: kCFBooleanTrue] as CFDictionary
        guard let modeList = CGDisplayCopyAllDisplayModes(display.id, options) as? [CGDisplayMode] else { return }
        
        let candidates = modeList.filter {
            $0.width == resolution.width &&
            $0.height == resolution.height &&
            $0.pixelWidth == resolution.pixelWidth &&
            $0.pixelHeight == resolution.pixelHeight
        }
        
        // Pick best matching refresh rate
        let targetMode = candidates.first(where: { abs($0.refreshRate - display.currentRefreshRate) < 0.1 }) ?? candidates.first
        
        if let mode = targetMode {
            let result = CGDisplaySetDisplayMode(display.id, mode, nil)
            if result == .success {
                refreshDisplays()
            }
        }
    }
    
    public func setBrightness(for display: DisplayModel, brightness: Float) {
        let clamped = max(0.0, min(1.0, brightness))
        brightnessMemory[display.id] = clamped
        
        if display.supportsHardwareBrightness {
            _ = DisplayBrightnessBridge.shared.setHardwareBrightness(displayID: display.id, brightness: clamped)
        } else {
            SoftwareDimmer.shared.setDimming(for: display.id, brightness: clamped)
        }
        
        if let index = displays.firstIndex(where: { $0.id == display.id }) {
            displays[index].brightness = clamped
        }
    }
    
    public func setWarmth(for display: DisplayModel, warmth: Float) {
        let clamped = max(0.0, min(1.0, warmth))
        warmthMemory[display.id] = clamped
        SoftwareDimmer.shared.setWarmth(for: display.id, warmth: clamped)
        
        if let index = displays.firstIndex(where: { $0.id == display.id }) {
            displays[index].warmth = clamped
        }
    }
    
    public func toggleBlackout(for display: DisplayModel) {
        let newState = !(blackoutMemory[display.id] ?? false)
        blackoutMemory[display.id] = newState
        SoftwareDimmer.shared.setBlackout(for: display.id, isBlackedOut: newState)
        
        if let index = displays.firstIndex(where: { $0.id == display.id }) {
            displays[index].isBlackedOut = newState
        }
    }
    
    // Global hotkey actions
    public func toggleRefreshRate() {
        for display in displays {
            guard display.availableRefreshRates.count > 1 else { continue }
            let lowest = display.availableRefreshRates.first ?? 60.0
            let highest = display.availableRefreshRates.last ?? 120.0
            let isNearLowest = abs(display.currentRefreshRate - lowest) < 0.1
            let newRate = isNearLowest ? highest : lowest
            setRefreshRate(for: display, rate: newRate)
        }
    }
    
    public func adjustBrightness(delta: Float) {
        for display in displays {
            let newBrightness = max(0.05, min(1.0, display.brightness + delta))
            setBrightness(for: display, brightness: newBrightness)
        }
    }
    
    public func toggleBlackoutForAll() {
        let anyBlackedOut = displays.contains(where: { $0.isBlackedOut })
        let targetState = !anyBlackedOut
        for display in displays {
            blackoutMemory[display.id] = targetState
            SoftwareDimmer.shared.setBlackout(for: display.id, isBlackedOut: targetState)
            if let index = displays.firstIndex(where: { $0.id == display.id }) {
                displays[index].isBlackedOut = targetState
            }
        }
    }
    
    // Quick Presets
    public func applyEcoMode() {
        selectedPreset = "Eco"
        for display in displays {
            if let lowestHz = display.availableRefreshRates.first {
                setRefreshRate(for: display, rate: lowestHz)
            }
            setBrightness(for: display, brightness: 0.40)
        }
    }
    
    public func applyProMotionMode() {
        selectedPreset = "ProMotion"
        for display in displays {
            if let highestHz = display.availableRefreshRates.last {
                setRefreshRate(for: display, rate: highestHz)
            }
            setBrightness(for: display, brightness: 1.0)
        }
    }
    
    public func applyNightMode() {
        selectedPreset = "Night"
        for display in displays {
            setBrightness(for: display, brightness: 0.25)
            setWarmth(for: display, warmth: 0.70)
        }
    }
}
