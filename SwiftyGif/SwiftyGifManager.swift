//
//  SwiftyGifManager.swift
//
//
import ImageIO
import UIKit
import Foundation

public class SwiftyGifManager {

    private var timer: CADisplayLink?
    private var displayViews: [UIImageView] = []
    private var totalGifSize: Int
    private var memoryLimit: Int
    public var  haveCache: Bool
    
    public init(memoryLimit: Int) {
        self.memoryLimit = memoryLimit
        self.totalGifSize = 0
        self.haveCache = true
        self.timer = CADisplayLink(target: self, selector: #selector(self.updateImageView))
        self.timer!.addToRunLoop(.mainRunLoop(), forMode: NSRunLoopCommonModes)
    }
    
    public func addImageView(imageView: UIImageView) {
        self.totalGifSize += imageView.gifImage!.imageSize!
        if self.totalGifSize > memoryLimit && self.haveCache {
            self.haveCache = false
            for imageView in self.displayViews{
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0)){
                    imageView.checkCache()
                }
            }
        }
        self.displayViews.append(imageView)
    }
    
    public func deleteImageView(imageView: UIImageView){
        if let index = self.displayViews.indexOf(imageView){
            self.displayViews.removeAtIndex(index)
            self.totalGifSize -= imageView.gifImage!.imageSize!
            if self.totalGifSize < memoryLimit && !self.haveCache {
                self.haveCache = true
                for imageView in self.displayViews{
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0)){
                        imageView.checkCache()
                    }
                }
            }
        }
    }
    
    public func containsImageView(imageView: UIImageView) -> Bool{
        return self.displayViews.contains(imageView)
    }
    
    public func hasCache(imageView: UIImageView) -> Bool{
        if imageView.displaying == false {
            return false
        }

        if imageView.loopTime == -1 || imageView.loopTime >= 5 {
            return self.haveCache
        }else{
            return false
        }
    }
       
    @objc func updateImageView(){
        for imageView in self.displayViews {
            dispatch_async(dispatch_get_main_queue()){
                imageView.image = imageView.currentImage
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0)){
                imageView.updateCurrentImage()
            }
        }
    }
    
}