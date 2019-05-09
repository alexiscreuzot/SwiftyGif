//
//  SwiftyGifManager.swift
//
//
import ImageIO
import UIKit
import Foundation

open class SwiftyGifManager {
    
    // A convenient default manager if we only have one gif to display here and there
    public static var defaultManager = SwiftyGifManager(memoryLimit: 50)
    
    fileprivate var timer: CADisplayLink?
    fileprivate var displayViews: [UIImageView] = []
    fileprivate var totalGifSize: Int
    fileprivate var memoryLimit: Int
    open var  haveCache: Bool
    
    /// Initialize a manager
    ///
    /// - Parameter memoryLimit: The number of Mb max for this manager
    public init(memoryLimit: Int) {
        self.memoryLimit = memoryLimit
        totalGifSize = 0
        haveCache = true
    }
    
    deinit {
        stopTimer()
    }
    
    public func startTimerIfNeeded() {
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
    
    public func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    /// Add a new imageView to this manager if it doesn't exist
    /// - Parameter imageView: The UIImageView we're adding to this manager
    open func addImageView(_ imageView: UIImageView) -> Bool {
        if containsImageView(imageView) {
            startTimerIfNeeded()
            return false
        }
        
        updateCacheSize(for: imageView, add: true)
        displayViews.append(imageView)
        startTimerIfNeeded()
        
        return true
    }
    
    /// Delete an imageView from this manager if it exists
    /// - Parameter imageView: The UIImageView we want to delete
    open func deleteImageView(_ imageView: UIImageView) {
        guard let index = displayViews.firstIndex(of: imageView) else {
            return
        }
        
        displayViews.remove(at: index)
        updateCacheSize(for: imageView, add: false)
    }
    
    open func updateCacheSize(for imageView: UIImageView, add: Bool) {
        totalGifSize += (add ? 1 : -1) * (imageView.gifImage?.imageSize ?? 0)
        haveCache = totalGifSize <= memoryLimit
        
        for imageView in displayViews {
            DispatchQueue.global(qos: .userInteractive).sync(execute: imageView.updateCache)
        }
    }
    
    open func clear() {
        displayViews.forEach { $0.clear() }
        displayViews = []
        stopTimer()
    }
    
    /// Check if an imageView is already managed by this manager
    /// - Parameter imageView: The UIImageView we're searching
    /// - Returns : a boolean for wether the imageView was found
    open func containsImageView(_ imageView: UIImageView) -> Bool{
        return displayViews.contains(imageView)
    }
    
    /// Check if this manager has cache for an imageView
    /// - Parameter imageView: The UIImageView we're searching cache for
    /// - Returns : a boolean for wether we have cache for the imageView
    open func hasCache(_ imageView: UIImageView) -> Bool{
        return imageView.displaying && (imageView.loopCount == -1 || imageView.loopCount >= 5) ? haveCache : false
    }
    
    /// Update imageView current image. This method is called by the main loop.
    /// This is what create the animation.
    @objc func updateImageView(){
        guard !displayViews.isEmpty else {
            stopTimer()
            return
        }
        
        for imageView in displayViews {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).sync {
                imageView.image = imageView.currentImage
            }
            
            if imageView.isAnimatingGif() {
                DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).sync(execute: imageView.updateCurrentImage)
            }
        }
    }
}
