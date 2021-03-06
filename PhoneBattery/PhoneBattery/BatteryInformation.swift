//
//  BatteryInformation.swift
//  PhoneBattery
//
//  Created by Marcel Voß on 21/02/2017.
//  Copyright © 2017 Marcel Voss. All rights reserved.
//

import UIKit

class BatteryInformation: NSObject {
    
    let device = UIDevice.current
    
    enum Style {
        case short
        case long
    }
    
    override init() {
        super.init()
        
        device.isBatteryMonitoringEnabled = true
    }
    
    var batteryState: Int {
        // Check if application is running in simulator; if so, return some state since running in simulator will always return 0
        #if arch(i386) || arch(x86_64)
            return 1
        #else
            return device.batteryState.rawValue
        #endif
    }
    
    var batteryLevel: Int {
        // Check if application is running in simulator; if so, return some number since battery level isn't supported in simulator
        #if arch(i386) || arch(x86_64)
            return 75
        #else
            return Int(device.batteryLevel * 100)
        #endif
    }
    
    var lowPowerModeEnabled: Bool {
        return ProcessInfo.processInfo.isLowPowerModeEnabled
    }
    
    func stringForBatteryState(state: Int, style: Style) -> String {
        if state == 1 {
            // Running on battery
            if style == .short {
                return NSLocalizedString("BATTERY_LEFT_SHORT", comment: "")
            } else {
                return NSLocalizedString("BATTERY_LEFT_LONG", comment: "")
            }
        } else if state == 2 {
            // Charging
            if style == .short {
                return NSLocalizedString("BATTERY_CHARGING_SHORT", comment: "")
            } else {
                return NSLocalizedString("BATTERY_CHARGING_LONG", comment: "")
            }
        } else if state == 3 {
            // Completed charging
            if style == .short {
                return NSLocalizedString("BATTERY_FULL_SHORT", comment: "")
            } else {
                return NSLocalizedString("BATTERY_FULL_LONG", comment: "")
            }
        } else {
            return NSLocalizedString("BATTERY_UNKNOWN", comment: "")
        }
    }
}
