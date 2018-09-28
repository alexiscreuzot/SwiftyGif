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
    
    /**
     Initialize a manager
     - Parameter memoryLimit: The number of Mb max for this manager
     */
    public init(memoryLimit: Int) {
        self.memoryLimit = memoryLimit
        totalGifSize = 0
        haveCache = true
        timer = CADisplayLink(target: self, selector: #selector(updateImageView))
        
        #if swift(>=4.2)
        timer?.add(to: .main, forMode: .common)
        #else
        timer?.add(to: .main, forMode: RunLoop.Mode.common)
        #endif
    }
    
    /**
     Add a new imageView to this manager if it doesn't exist
     - Parameter imageView: The UIImageView we're adding to this manager
     */
    open func addImageView(_ imageView: UIImageView) -> Bool {
        if containsImageView(imageView) {
            return false
        }
        
        totalGifSize += imageView.gifImage?.imageSize ?? 0
        
        if totalGifSize > memoryLimit && haveCache {
            haveCache = false
            for imageView in displayViews{
                DispatchQueue.global(qos: .userInteractive).sync{
                    imageView.updateCache()
                }
            }
        }
        displayViews.append(imageView)
        return true
    }
    
    open func clear() {
        while !displayViews.isEmpty {
            displayViews.removeFirst().clear()
        }
    }
    
    /**
     Delete an imageView from this manager if it exists
     - Parameter imageView: The UIImageView we want to delete
     */
    open func deleteImageView(_ imageView: UIImageView){
        
        if let index = self.displayViews.index(of: imageView){
            if index >= 0 && index < self.displayViews.count {
                displayViews.remove(at: index)
                totalGifSize -= imageView.gifImage?.imageSize ?? 0
                if totalGifSize < memoryLimit && !haveCache {
                    haveCache = true
                    for imageView in displayViews {
                        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).sync{
                            imageView.updateCache()
                        }
                    }
                }
            }
        }
    }
    
    /**
     Check if an imageView is already managed by this manager
     - Parameter imageView: The UIImageView we're searching
     - Returns : a boolean for wether the imageView was found
     */
    open func containsImageView(_ imageView: UIImageView) -> Bool{
        return displayViews.contains(imageView)
    }
    
    /**
     Check if this manager has cache for an imageView
     - Parameter imageView: The UIImageView we're searching cache for
     - Returns : a boolean for wether we have cache for the imageView
     */
    open func hasCache(_ imageView: UIImageView) -> Bool{
        if imageView.displaying == false {
            return false
        }
        
        if imageView.loopCount == -1 || imageView.loopCount >= 5 {
            return haveCache
        }else{
            return false
        }
    }
    
    /**
     Update imageView current image. This method is called by the main loop.
     This is what create the animation.
     */
    @objc func updateImageView(){
        for imageView in displayViews {

            DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).sync{
                imageView.image = imageView.currentImage
            }
            if imageView.isAnimatingGif() {
                DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).sync{
                    imageView.updateCurrentImage()
                }
            }

        }
    }
    
}
