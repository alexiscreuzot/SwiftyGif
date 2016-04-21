//
//  SwiftyGifManager.swift
//
//
import ImageIO
import UIKit
import Foundation

public class SwiftyGifManager {

    // A convenient default manager if we only have one gif to display here and there
    static var defaultManager = SwiftyGifManager(memoryLimit: 50)
    
    private var timer: CADisplayLink?
    private var displayViews: [UIImageView] = []
    private var totalGifSize: Int
    private var memoryLimit: Int
    public var  haveCache: Bool

    /**
     Initialize a manager
     - Parameter memoryLimit: The number of Mb max for this manager
     */
    public init(memoryLimit: Int) {
        self.memoryLimit = memoryLimit
        self.totalGifSize = 0
        self.haveCache = true
        self.timer = CADisplayLink(target: self, selector: #selector(self.updateImageView))
        self.timer!.addToRunLoop(.mainRunLoop(), forMode: NSRunLoopCommonModes)
    }

    /**
     Add a new imageView to this manager if it doesn't exist
     - Parameter imageView: The UIImageView we're adding to this manager
     */
    public func addImageView(imageView: UIImageView) {
        if self.containsImageView(imageView) { return }

        self.totalGifSize += imageView.gifImage!.imageSize!
        if self.totalGifSize > memoryLimit && self.haveCache {
            self.haveCache = false
            for imageView in self.displayViews{
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0)){
                    imageView.updateCache()
                }
            }
        }
        self.displayViews.append(imageView)
    }

    /**
     Delete an imageView from this manager if it exists
     - Parameter imageView: The UIImageView we want to delete
     */
    public func deleteImageView(imageView: UIImageView){

        if let index = self.displayViews.indexOf(imageView) {


                self.displayViews.removeAtIndex(index)
                self.totalGifSize -= imageView.gifImage!.imageSize!
                if self.totalGifSize < memoryLimit && !self.haveCache {
                    self.haveCache = true
                    for imageView in self.displayViews{
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0)){
                            imageView.updateCache()
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
    public func containsImageView(imageView: UIImageView) -> Bool{
        return self.displayViews.contains(imageView)
    }

    /**
     Check if this manager has cache for an imageView
     - Parameter imageView: The UIImageView we're searching cache for
     - Returns : a boolean for wether we have cache for the imageView
     */
    public func hasCache(imageView: UIImageView) -> Bool{
        if imageView.displaying == false {
            return false
        }

        if imageView.loopCount == -1 || imageView.loopCount >= 5 {
            return self.haveCache
        }else{
            return false
        }
    }

    /**
     Update imageView current image. This method is called by the main loop.
     This is what create the animation.
     */
    @objc func updateImageView(){

        for imageView in self.displayViews {

            dispatch_async(dispatch_get_main_queue()){
                imageView.image = imageView.currentImage
            }
            if imageView.isAnimatingGif() {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0)){
                    imageView.updateCurrentImage()
                }
            }

        }
    }
    
}