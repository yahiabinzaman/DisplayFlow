import Foundation
import CoreGraphics
import AppKit

public struct DisplayResolution: Identifiable, Hashable {
    public var id: String { "\(width)x\(height)_\(pixelWidth)x\(pixelHeight)" }
    public let width: Int
    public let height: Int
    public let pixelWidth: Int
    public let pixelHeight: Int
    public let isHiDPI: Bool
    
    public var title: String {
        if isHiDPI {
            return "\(width) × \(height) (Retina)"
        } else {
            return "\(pixelWidth) × \(pixelHeight)"
        }
    }
}

public struct DisplayModel: Identifiable, Hashable {
    public let id: CGDirectDisplayID
    public var name: String
    public var isBuiltin: Bool
    public var isMain: Bool
    public var width: Int
    public var height: Int
    public var pixelWidth: Int
    public var pixelHeight: Int
    public var currentRefreshRate: Double
    public var availableRefreshRates: [Double]
    public var availableResolutions: [DisplayResolution]
    public var brightness: Float // 0.0 - 1.0
    public var warmth: Float // 0.0 - 1.0 (Color Temperature / Blue light filter)
    public var isBlackedOut: Bool
    public var supportsHardwareBrightness: Bool
    
    public var resolutionString: String {
        if pixelWidth != width && width > 0 {
            return "\(width) × \(height) (Retina)"
        }
        return "\(pixelWidth) × \(pixelHeight)"
    }
    
    public var formattedCurrentHz: String {
        if currentRefreshRate.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(currentRefreshRate))Hz"
        } else {
            return String(format: "%.1fHz", currentRefreshRate)
        }
    }
    
    public func formattedHz(_ rate: Double) -> String {
        if rate.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(rate))Hz"
        } else {
            return String(format: "%.1fHz", rate)
        }
    }
}
