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
        self.totalGifSize = 0
        self.haveCache = true
        self.timer = CADisplayLink(target: self, selector: #selector(self.updateImageView))
        self.timer!.add(to: .main, forMode: RunLoopMode.commonModes)
    }
    
    /**
     Add a new imageView to this manager if it doesn't exist
     - Parameter imageView: The UIImageView we're adding to this manager
     */
    open func addImageView(_ imageView: UIImageView) {
        if self.containsImageView(imageView) { return }
        
        self.totalGifSize += imageView.gifImage!.imageSize!
        if self.totalGifSize > memoryLimit && self.haveCache {
            self.haveCache = false
            for imageView in self.displayViews{
                DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).sync{
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
    open func deleteImageView(_ imageView: UIImageView){
        
        if let index = self.displayViews.index(of: imageView){
            if index >= 0 && index < self.displayViews.count {
                self.displayViews.remove(at: index)
                self.totalGifSize -= imageView.gifImage!.imageSize!
                if self.totalGifSize < memoryLimit && !self.haveCache {
                    self.haveCache = true
                    for imageView in self.displayViews{
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
        return self.displayViews.contains(imageView)
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

            DispatchQueue.main.async{
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
