//
//  PreviewWatchView.swift
//  PhoneBattery
//
//  Created by Marcel Voß on 08.04.17.
//  Copyright © 2017 Marcel Voss. All rights reserved.
//

import UIKit

class PreviewWatchView: UIView {
    
    fileprivate let batteryObject = WatchManager.sharedInstance.battery
    fileprivate let settings = SettingsModel()
    
    var timer: Timer?
    let timeLabel = UILabel()
    let appLabel = UILabel()
    fileprivate let contentView = UIView()
    fileprivate let batteryStatusLabel = UILabel()
    fileprivate let batteryImageView = UIImageView()
    fileprivate let batteryPercentageLabel = UILabel()
    fileprivate let watchImageView = UIImageView(image: UIImage(named: "WatchSteel"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshBatteryInformation), name: NSNotification.Name("RefreshBatteryInformation"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshBatteryInformation),
                                               name: NSNotification.Name.UIDeviceBatteryLevelDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshBatteryInformation),
                                               name: NSNotification.Name.UIDeviceBatteryStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshBatteryInformation),
                                               name: NSNotification.Name.NSProcessInfoPowerStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setupInterface), name: NSNotification.Name("WatchInterfaceDidChange"), object: nil)
        
        
        setupWatch()
        setupInterface()
        
        timer?.fire()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(refreshTime), userInfo: nil, repeats: true)
    }
    
    deinit {
        timer?.invalidate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupWatch() {
        watchImageView.translatesAutoresizingMaskIntoConstraints = false
        watchImageView.contentMode = .scaleAspectFit
        addSubview(watchImageView)
        
        addConstraint(NSLayoutConstraint(item: watchImageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: watchImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: watchImageView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1.0, constant: -40))
        
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .black
        watchImageView.addSubview(contentView)
        
        watchImageView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .centerX, relatedBy: .equal, toItem: watchImageView, attribute: .centerX, multiplier: 1.0, constant: -4))
        
        watchImageView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .centerY, relatedBy: .equal, toItem: watchImageView, attribute: .centerY, multiplier: 1.0, constant: 0))
        
        watchImageView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .height, relatedBy: .equal, toItem: watchImageView, attribute: .height, multiplier: 1.0, constant: -50))
        
        watchImageView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 120))
        
        
        appLabel.text = "PhoneBattery"
        appLabel.textColor = .phoneBatteryGreen
        appLabel.translatesAutoresizingMaskIntoConstraints = false
        appLabel.font = UIFont.boldSystemFont(ofSize: 10)
        contentView.addSubview(appLabel)
        
        contentView.addConstraint(NSLayoutConstraint(item: appLabel, attribute: .left, relatedBy: .equal, toItem: contentView, attribute: .left, multiplier: 1.0, constant: 0))
        
        contentView.addConstraint(NSLayoutConstraint(item: appLabel, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 0))
        
        
        timeLabel.textColor = .white
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = UIFont.boldSystemFont(ofSize: 10)
        timeLabel.textAlignment = .right
        contentView.addSubview(timeLabel)
        
        contentView.addConstraint(NSLayoutConstraint(item: timeLabel, attribute: .right, relatedBy: .equal, toItem: contentView, attribute: .right, multiplier: 1.0, constant: 0))
        
        contentView.addConstraint(NSLayoutConstraint(item: timeLabel, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1.0, constant: 0))
        
        
        
        refreshTime()
        refreshBatteryInformation()
    }
    
    func setupInterface() {
        let proxyView = UIView()
        proxyView.translatesAutoresizingMaskIntoConstraints = false
        proxyView.backgroundColor = .black
        contentView.addSubview(proxyView)
        
        contentView.addConstraint(NSLayoutConstraint(item: proxyView, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1.0, constant: 0))
        
        contentView.addConstraint(NSLayoutConstraint(item: proxyView, attribute: .top, relatedBy: .equal, toItem: appLabel, attribute: .bottom, multiplier: 1.0, constant: 0))
        
        contentView.addConstraint(NSLayoutConstraint(item: proxyView, attribute: .height, relatedBy: .equal, toItem: contentView, attribute: .height, multiplier: 1.0, constant: -10))
        
        contentView.addConstraint(NSLayoutConstraint(item: proxyView, attribute: .width, relatedBy: .equal, toItem: contentView, attribute: .width, multiplier: 1.0, constant: 0))
        
        layoutIfNeeded()
        
        
        
        batteryImageView.removeFromSuperview()
        batteryImageView.translatesAutoresizingMaskIntoConstraints = false
        batteryImageView.contentMode = .scaleAspectFit
        proxyView.addSubview(batteryImageView)
        
        addConstraint(NSLayoutConstraint(item: batteryImageView, attribute: .centerX, relatedBy: .equal, toItem: proxyView, attribute: .centerX, multiplier: 1.0, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: batteryImageView, attribute: .width, relatedBy: .equal, toItem: proxyView, attribute: .width, multiplier: 0.9, constant: 0))
        
        if settings.useCircularIndicator {
            addConstraint(NSLayoutConstraint(item: batteryImageView, attribute: .centerY, relatedBy: .equal, toItem: proxyView, attribute: .centerY, multiplier: 1.0, constant: 0))
        } else {
            addConstraint(NSLayoutConstraint(item: batteryImageView, attribute: .centerY, relatedBy: .equal, toItem: proxyView, attribute: .centerY, multiplier: 1.0, constant: -10))
        }
        
        
        
        // Remove batteryPercentageLabel due to new layout attributes
        batteryPercentageLabel.removeFromSuperview()
        
        batteryPercentageLabel.textColor = .white
        batteryPercentageLabel.translatesAutoresizingMaskIntoConstraints = false
        batteryPercentageLabel.textAlignment = .center
        batteryImageView.addSubview(batteryPercentageLabel)
        
        batteryImageView.addConstraint(NSLayoutConstraint(item: batteryPercentageLabel, attribute: .centerX, relatedBy: .equal, toItem: batteryImageView, attribute: .centerX, multiplier: 1.0, constant: 0))
        
        if settings.useCircularIndicator {
            batteryPercentageLabel.font = UIFont.systemFont(ofSize: 15)
            
            batteryImageView.addConstraint(NSLayoutConstraint(item: batteryPercentageLabel, attribute: .centerY, relatedBy: .equal, toItem: batteryImageView, attribute: .centerY, multiplier: 1.0, constant: -6))
        } else {
            batteryPercentageLabel.font = UIFont.boldSystemFont(ofSize: 11)
            
            batteryImageView.addConstraint(NSLayoutConstraint(item: batteryPercentageLabel, attribute: .centerY, relatedBy: .equal, toItem: batteryImageView, attribute: .centerY, multiplier: 1.0, constant: 0))
        }
        
        
        batteryStatusLabel.removeFromSuperview()
        
        batteryStatusLabel.textColor = .white
        batteryStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        batteryStatusLabel.font = UIFont.systemFont(ofSize: 10)
        batteryStatusLabel.numberOfLines = 0
        batteryStatusLabel.textAlignment = .center
        
        if settings.useCircularIndicator {
            batteryImageView.addSubview(batteryStatusLabel)
            
            batteryImageView.addConstraint(NSLayoutConstraint(item: batteryStatusLabel, attribute: .top, relatedBy: .equal, toItem: batteryPercentageLabel, attribute: .bottom, multiplier: 1.0, constant: 0))
            
            batteryImageView.addConstraint(NSLayoutConstraint(item: batteryStatusLabel, attribute: .centerX, relatedBy: .equal, toItem: batteryImageView, attribute: .centerX, multiplier: 1.0, constant: 0))
        } else {
            proxyView.addSubview(batteryStatusLabel)
            
            proxyView.addConstraint(NSLayoutConstraint(item: batteryStatusLabel, attribute: .width, relatedBy: .equal, toItem: proxyView, attribute: .width, multiplier: 1.0, constant: 0))
            
            proxyView.addConstraint(NSLayoutConstraint(item: batteryStatusLabel, attribute: .top, relatedBy: .equal, toItem: batteryImageView, attribute: .bottom, multiplier: 1.0, constant: -3))
            
            proxyView.addConstraint(NSLayoutConstraint(item: batteryStatusLabel, attribute: .centerX, relatedBy: .equal, toItem: proxyView, attribute: .centerX, multiplier: 1.0, constant: 0))
        }
        
        refreshBatteryInformation()
        animateWatch()
    }
    
    func refreshTime() {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateFormat = "HH:mm"
        timeLabel.text = dateFormatter.string(from: Date())
    }
    
    func animateWatch() {
        var images = [UIImage]()
        
        for i in 0 ... batteryObject.batteryLevel {
            var batteryImage: UIImage?
            
            if settings.useCircularIndicator {
                if batteryObject.lowPowerModeEnabled {
                    batteryImage = UIImage(named: "CircularLowPowerFrame-\(i)")
                } else {
                    batteryImage = UIImage(named: "CircularFrame-\(i)")
                }
            } else {
                if batteryObject.lowPowerModeEnabled {
                    batteryImage = UIImage(named: "BatteryLowPowerFrame-\(i)")
                } else {
                    batteryImage = UIImage(named: "BatteryFrame-\(i)")
                }
            }
            
            if let image = batteryImage {
                images.append(image)
            }
        }
        
        batteryImageView.image = images.last
        batteryImageView.animationImages = images
        batteryImageView.animationDuration = 1
        batteryImageView.animationRepeatCount = 1
        batteryImageView.startAnimating()
    }
    
    func refreshBatteryInformation() {
        batteryPercentageLabel.text = "\(batteryObject.batteryLevel)%"
        
        if settings.useCircularIndicator {
            if batteryObject.lowPowerModeEnabled {
                batteryImageView.image = UIImage(named: "CircularLowPowerFrame-\(batteryObject.batteryLevel)")
            } else {
                batteryImageView.image = UIImage(named: "CircularFrame-\(batteryObject.batteryLevel)")
            }
            
            batteryStatusLabel.text = batteryObject.stringForBatteryState(state: batteryObject.batteryState, style: .short)
        } else {
            if batteryObject.lowPowerModeEnabled {
                batteryImageView.image = UIImage(named: "BatteryLowPowerFrame-\(batteryObject.batteryLevel)")
            } else {
                batteryImageView.image = UIImage(named: "BatteryFrame-\(batteryObject.batteryLevel)")
            }
            
            batteryStatusLabel.text = batteryObject.stringForBatteryState(state: batteryObject.batteryState, style: .long)
        }
    }

}
