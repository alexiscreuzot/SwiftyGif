//
//  SwiftyGifManager.swift
//
//
import ImageIO

#if os(macOS)
import AppKit
import CoreVideo
#else
import UIKit
#endif

#if os(macOS)
public typealias PlatformImageView = NSImageView
#else
public typealias PlatformImageView = UIImageView
#endif

open class SwiftyGifManager {
    
    // A convenient default manager if we only have one gif to display here and there
    public static var defaultManager = SwiftyGifManager(memoryLimit: 50)
    
    #if os(macOS)
    fileprivate var timer: CVDisplayLink?
    #else
    fileprivate var timer: CADisplayLink?
    #endif
    
    fileprivate var displayViews: [PlatformImageView] = []
    fileprivate var totalGifSize: Int
    fileprivate var memoryLimit: Int
    open var haveCache: Bool
    open var remoteCache : [URL : Data] = [:]
    
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
        
        #if os(macOS)
        
        func displayLinkOutputCallback(displayLink: CVDisplayLink,
                                       _ inNow: UnsafePointer<CVTimeStamp>,
                                       _ inOutputTime: UnsafePointer<CVTimeStamp>,
                                       _ flagsIn: CVOptionFlags,
                                       _ flagsOut: UnsafeMutablePointer<CVOptionFlags>,
                                       _ displayLinkContext: UnsafeMutableRawPointer?) -> CVReturn {
            unsafeBitCast(displayLinkContext!, to: SwiftyGifManager.self).updateImageView()
            return kCVReturnSuccess
        }

        CVDisplayLinkCreateWithActiveCGDisplays(&timer)
        CVDisplayLinkSetOutputCallback(timer!, displayLinkOutputCallback, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
        CVDisplayLinkStart(timer!)
        
        #else
        
        timer = CADisplayLink(target: self, selector: #selector(updateImageView))
        
        #if swift(>=4.2)
        timer?.add(to: .main, forMode: .common)
        #else
        timer?.add(to: .main, forMode: RunLoopMode.commonModes)
        #endif
        
        #endif
    }
    
    public func stopTimer() {
        #if os(macOS)
        CVDisplayLinkStop(timer!)
        #else
        timer?.invalidate()
        #endif
        
        timer = nil
    }
    
    /// Add a new imageView to this manager if it doesn't exist
    /// - Parameter imageView: The image view we're adding to this manager
    open func addImageView(_ imageView: PlatformImageView) -> Bool {
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
    /// - Parameter imageView: The image view we want to delete
    open func deleteImageView(_ imageView: PlatformImageView) {
        guard let index = displayViews.firstIndex(of: imageView) else {
            return
        }
        
        displayViews.remove(at: index)
        updateCacheSize(for: imageView, add: false)
    }
    
    open func updateCacheSize(for imageView: PlatformImageView, add: Bool) {
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
    /// - Parameter imageView: The image view we're searching
    /// - Returns : a boolean for wether the imageView was found
    open func containsImageView(_ imageView: PlatformImageView) -> Bool{
        return displayViews.contains(imageView)
    }
    
    /// Check if this manager has cache for an imageView
    /// - Parameter imageView: The image view we're searching cache for
    /// - Returns : a boolean for wether we have cache for the imageView
    open func hasCache(_ imageView: PlatformImageView) -> Bool {
        return imageView.displaying && (imageView.loopCount == -1 || imageView.loopCount >= 5) ? haveCache : false
    }
    
    /// Update imageView current image. This method is called by the main loop.
    /// This is what create the animation.
    @objc func updateImageView() {
        guard !displayViews.isEmpty else {
            stopTimer()
            return
        }
        
        #if os(macOS)
        let queue = DispatchQueue.main
        #else
        let queue = DispatchQueue.global(qos: .userInteractive)
        #endif
        
        for imageView in displayViews {
            queue.sync {
                imageView.image = imageView.currentImage
            }
            
            if imageView.isAnimatingGif() {
                queue.sync(execute: imageView.updateCurrentImage)
            }
        }
    }
}
