//
//  Manager.swift
//
//

import UIKit

final class Manager {
    
    // A convenient default manager if we only have one gif to display here and there
    static let shared = Manager()
    
    private var timer: CADisplayLink?
    private var totalGifSize: Int = 0
    private var configList: [Config] = []

    deinit {
        stopTimer()
    }
    
    func manage(_ config: Config) {
        configList.append(config)
        startTimerIfNeeded()
    }
    
    func startTimerIfNeeded() {
        guard timer == nil else {
            return
        }
        
        timer = CADisplayLink(target: self, selector: #selector(updateImageView))
        
        #if swift(>=4.2)
        timer?.add(to: .main, forMode: .common)
        #else
        timer?.add(to: .main, forMode: RunLoopMode.commonModes)
        #endif
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func clear() {
        configList.forEach { $0.imageViews.forEach { $0.clear() } }
        configList = []
        stopTimer()
    }
    
    /// Update imageView current image. This method is called by the main loop.
    /// This is what create the animation.
    @objc func updateImageView(){
        var timerShouldStop = true
        
        for config in configList {
            for imageView in config.imageViews {
                timerShouldStop = false
                
                DispatchQueue.global(qos: .userInteractive).sync {
                    imageView.image = imageView.currentImage
                }
                
                if imageView.isAnimatingGif() {
                    DispatchQueue.global(qos: .userInteractive).sync(execute: imageView.updateCurrentImage)
                }
            }
        }
        
        if timerShouldStop {
            stopTimer()
        }
    }
}
