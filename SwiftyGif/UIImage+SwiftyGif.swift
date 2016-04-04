//
//  UIImage+SwiftyGif.swift
//

import ImageIO
import UIKit

let _imageSourceKey = malloc(4)
let _displayRefreshFactorKey = malloc(4)
let _imageCountKey = malloc(4)
let _displayOrderKey = malloc(4)
let _imageSizeKey = malloc(4)

let defaultLevelOfIntegrity: Float = 0.8

public extension UIImage{

    // PRAGMA - Inits

    public convenience init(gifData:NSData) {
        self.init()
        setGifFromData(gifData,levelOfIntegrity: defaultLevelOfIntegrity)
    }

    public convenience init(gifData:NSData, levelOfIntegrity:Float) {
        self.init()
        setGifFromData(gifData,levelOfIntegrity: levelOfIntegrity)
    }

    public convenience init(gifName: String) {
        self.init()
        setGif(gifName, levelOfIntegrity: defaultLevelOfIntegrity)
    }

    public convenience init(gifName: String, levelOfIntegrity: Float) {
        self.init()
        setGif(gifName, levelOfIntegrity: levelOfIntegrity)
    }

    public func setGifFromData(data:NSData,levelOfIntegrity:Float) {
        imageSource = CGImageSourceCreateWithData(data, nil)
        calculateFrameDelay(delayTimes(imageSource), levelOfIntegrity: levelOfIntegrity)
        calculateFrameSize()
    }

    public func setGif(name: String) {
        setGif(name, levelOfIntegrity: defaultLevelOfIntegrity)
    }

    public func setGif(name: String, levelOfIntegrity: Float) {
        if let url = NSBundle.mainBundle().URLForResource(name, withExtension: "gif") {
            if let data = NSData(contentsOfURL:url) {
                setGifFromData(data,levelOfIntegrity: levelOfIntegrity)
            } else {
                print("Error : Invalid GIF data for \(name).gif")
            }
        } else {
            print("Error : Gif file \(name).gif not found")
        }
    }

    // PRAGMA - Logic
    
    private func delayTimes(imageSource:CGImageSourceRef?)->[Float]{
        
        let imageCount = CGImageSourceGetCount(imageSource!)
        var imageProperties = [CFDictionary]()
        for i in 0..<imageCount{
            imageProperties.append(CGImageSourceCopyPropertiesAtIndex(imageSource!, i, nil)!)
        }
        
        let frameProperties = imageProperties.map(){
            unsafeBitCast(
                CFDictionaryGetValue($0,
                    unsafeAddressOf(kCGImagePropertyGIFDictionary)),CFDictionary.self)
        }
        
        let EPS:Float = 1e-6
        let frameDelays:[Float] = frameProperties.map(){
            var delayObject: AnyObject = unsafeBitCast(
                CFDictionaryGetValue($0,
                    unsafeAddressOf(kCGImagePropertyGIFUnclampedDelayTime)),
                AnyObject.self)
            
            if(delayObject.floatValue<EPS){
                delayObject = unsafeBitCast(CFDictionaryGetValue($0,
                    unsafeAddressOf(kCGImagePropertyGIFDelayTime)), AnyObject.self)
            }
            return delayObject as! Float
        }
        return frameDelays
    }
    
    private func calculateFrameDelay(delaysArray:[Float],levelOfIntegrity:Float){
        
        var delays = delaysArray
        
        //Factors send to CADisplayLink.frameInterval
        let displayRefreshFactors = [60,30,20,15,12,10,6,5,4,3,2,1]
        
        //maxFramePerSecond,default is 60
        let maxFramePerSecond = displayRefreshFactors.first
        
        //frame numbers per second
        let displayRefreshRates = displayRefreshFactors.map{maxFramePerSecond!/$0}
        
        //time interval per frame
        let displayRefreshDelayTime = displayRefreshRates.map{1.0/Float($0)}
        
        //caclulate the time when eash frame should be displayed at(start at 0)
        for i in 1..<delays.count{ delays[i]+=delays[i-1] }
        
        //find the appropriate Factors then BREAK
        for i in 0..<displayRefreshDelayTime.count{
            
            let displayPosition = delays.map{Int($0/displayRefreshDelayTime[i])}
            
            var framelosecount: Float = 0
            for j in 1..<displayPosition.count{
                if displayPosition[j] == displayPosition[j-1] {
                    framelosecount += 1
                }
            }
            
            if framelosecount <= Float(displayPosition.count) * (1.0 - levelOfIntegrity) ||
                i == displayRefreshDelayTime.count-1 {
                
                self.imageCount = displayPosition.last!
                self.displayRefreshFactor = displayRefreshFactors[i]
                self.displayOrder = [Int]()
                var indexOfold = 0, indexOfnew = 1
                while(indexOfnew<=imageCount){
                    if(indexOfnew <= displayPosition[indexOfold]){
                        self.displayOrder!.append(indexOfold)
                        indexOfnew += 1
                    }else{indexOfold += 1}
                }
                break
            }
        }
    }

    private func calculateFrameSize(){
        let image = UIImage(CGImage: CGImageSourceCreateImageAtIndex(self.imageSource!,0,nil)!)
        self.imageSize = Int(image.size.height*image.size.width*4)*self.imageCount!/1000000
    }

    // PRAGMA - get / set associated values

    public var imageSource: CGImageSource? {
        get {
            return (objc_getAssociatedObject(self, _imageSourceKey) as! CGImageSource?)
        }
        set {
            objc_setAssociatedObject(self, _imageSourceKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
        }
    }

    public var displayRefreshFactor: Int?{
        get {
            return (objc_getAssociatedObject(self, _displayRefreshFactorKey) as! Int)
        }
        set {
            objc_setAssociatedObject(self, _displayRefreshFactorKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
        }
    }

    public var imageSize: Int?{
        get {
            return (objc_getAssociatedObject(self, _imageSizeKey) as! Int)
        }
        set {
            objc_setAssociatedObject(self, _imageSizeKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
        }
    }

    public var imageCount: Int?{
        get {
            return (objc_getAssociatedObject(self, _imageCountKey) as! Int)
        }
        set {
            objc_setAssociatedObject(self, _imageCountKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
        }
    }

    public var displayOrder: [Int]?{
        get {
            return (objc_getAssociatedObject(self, _displayOrderKey) as! [Int])
        }
        set {
            objc_setAssociatedObject(self, _displayOrderKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
        }
    }
}
