//
//  UIImageView+SwiftyGif.swift
//

import ImageIO
import UIKit

let _gifImageKey = malloc(4)
let _cacheKey = malloc(4)
let _currentImageKey = malloc(4)
let _displayOrderIndexKey = malloc(4)
let _syncFactorKey = malloc(4)
let _haveCacheKey = malloc(4)
let _loopTimeKey = malloc(4)
let _displayingKey = malloc(4)
let _animationManagerKey = malloc(4)

public extension UIImageView {

    // PRAGMA - Inits

    public convenience init(gifImage:UIImage, manager:SwiftyGifManager = SwiftyGifManager.defaultManager) {
        self.init()
        setGifImage(gifImage,manager: manager,loopTime: -1);
    }

    public convenience init(gifImage:UIImage, manager:SwiftyGifManager = SwiftyGifManager.defaultManager, loopTime:Int) {
        self.init()
        setGifImage(gifImage,manager: manager,loopTime: loopTime);
    }

    public func setGifImage(gifImage:UIImage, manager:SwiftyGifManager = SwiftyGifManager.defaultManager) {
        setGifImage(gifImage, manager: manager, loopTime: -1)
    }

    public func setGifImage(gifImage:UIImage, manager:SwiftyGifManager = SwiftyGifManager.defaultManager, loopTime:Int) {

        self.loopTime = loopTime
        self.gifImage = gifImage
        self.animationManager = manager
        self.syncFactor = 0
        self.displayOrderIndex = 0
        self.cache = NSCache()
        self.haveCache = false

        if let gif = self.gifImage {

            if let source = gif.imageSource {
                self.currentImage = UIImage(CGImage: CGImageSourceCreateImageAtIndex(source, 0, nil)!)

                if !manager.containsImageView(self) {
                    manager.addImageView(self)
                    startDisplay()
                }
            }
        }
    }

    // PRAGMA - Logic

    public func startDisplay() {
        self.displaying = true
        checkCache()
    }

    public func stopDisplay() {
        self.displaying = false
        checkCache()
    }

    public func checkCache() {
        if self.animationManager.hasCache(self) && !self.haveCache {
            prepareCache()
            self.haveCache = true
        }else if !self.animationManager.hasCache(self) && self.haveCache {
            self.cache.removeAllObjects()
            self.haveCache = false
        }
    }

    public func updateCurrentImage() {
        if self.displaying {
            if !self.haveCache {
                self.currentImage = UIImage(CGImage: CGImageSourceCreateImageAtIndex(self.gifImage!.imageSource!,self.gifImage!.displayOrder![self.displayOrderIndex],nil)!)
            }else{
                if let image = (cache.objectForKey(self.displayOrderIndex) as? UIImage) {
                    self.currentImage = image
                }else{
                    self.currentImage = UIImage(CGImage: CGImageSourceCreateImageAtIndex(self.gifImage!.imageSource!,self.gifImage!.displayOrder![self.displayOrderIndex],nil)!)
                }//prevent case that cache is not ready
            }
            updateIndex()
            if loopTime == 0 || !isDisplayedInScreen(self) {
                stopDisplay()
            }
        }else{
            if(isDisplayedInScreen(self) && loopTime != 0) {
                startDisplay()
            }
            if isDiscarded(self) {
                self.animationManager.deleteImageView(self)
            }
        }
    }

    public func isDiscarded(imageView:UIView?) -> Bool{
        if(imageView == nil || imageView!.superview == nil) {
            return true
        }
        return false
    }


    public func isDisplayedInScreen(imageView:UIView?) ->Bool{
        if (self.hidden) {
            return false
        }

        let screenRect = UIScreen.mainScreen().bounds
        let viewRect = imageView!.convertRect(self.frame,toView:UIApplication.sharedApplication().keyWindow)

        let intersectionRect = CGRectIntersection(viewRect, screenRect);
        if (CGRectIsEmpty(intersectionRect) || CGRectIsNull(intersectionRect)) {
            return false
        }
        return (self.window != nil)
    }

    private func updateIndex() {
        if let gif = self.gifImage {
            self.syncFactor = (self.syncFactor+1) % gif.displayRefreshFactor!
            if self.syncFactor == 0 {
                self.displayOrderIndex = (self.displayOrderIndex+1) % gif.imageCount!
                if displayOrderIndex == 0 && self.loopTime > 0 {
                    self.loopTime -= 1;
                }
            }
        }
    }

    private func prepareCache() {
        self.cache.removeAllObjects()

        if let gif = self.gifImage {
            for i in 0 ..< gif.displayOrder!.count {
                let image = UIImage(CGImage: CGImageSourceCreateImageAtIndex(gif.imageSource!, gif.displayOrder![i],nil)!)
                self.cache.setObject(image,forKey:i)
            }
        }
    }

    // PRAGMA - get / set associated values

    public var gifImage: UIImage? {
        get {
            return (objc_getAssociatedObject(self, _gifImageKey) as! UIImage?)
        }
        set {
            objc_setAssociatedObject(self, _gifImageKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
        }
    }
    public var currentImage: UIImage {
        get {
            return (objc_getAssociatedObject(self, _currentImageKey) as! UIImage)
        }
        set {
            objc_setAssociatedObject(self, _currentImageKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
        }
    }

    private var displayOrderIndex: Int {
        get {
            return (objc_getAssociatedObject(self, _displayOrderIndexKey) as! Int)
        }
        set {
            objc_setAssociatedObject(self, _displayOrderIndexKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
        }
    }

    private var syncFactor: Int {
        get {
            return (objc_getAssociatedObject(self, _syncFactorKey) as! Int)
        }
        set {
            objc_setAssociatedObject(self, _syncFactorKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
        }
    }

    public var loopTime: Int {
        get {
            return (objc_getAssociatedObject(self, _loopTimeKey) as! Int)
        }
        set {
            objc_setAssociatedObject(self, _loopTimeKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
        }
    }

    public var animationManager: SwiftyGifManager {
        get {
            return (objc_getAssociatedObject(self, _animationManagerKey) as! SwiftyGifManager)
        }
        set {
            objc_setAssociatedObject(self, _animationManagerKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
        }
    }

    private var haveCache: Bool {
        get {
            return (objc_getAssociatedObject(self, _haveCacheKey) as! Bool)
        }
        set {
            objc_setAssociatedObject(self, _haveCacheKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
        }
    }

    public var displaying: Bool {
        get {
            return (objc_getAssociatedObject(self, _displayingKey) as! Bool)
        }
        set {
            objc_setAssociatedObject(self, _displayingKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
        }
    }

    private var cache: NSCache {
        get {
            return (objc_getAssociatedObject(self, _cacheKey) as! NSCache)
        }
        set {
            objc_setAssociatedObject(self, _cacheKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
        }
    }
}
