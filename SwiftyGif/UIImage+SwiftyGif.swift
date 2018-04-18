//
//  UIImage+SwiftyGif.swift
//

import ImageIO
import UIKit

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func <= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l <= r
    default:
        return !(rhs < lhs)
    }
}

let _imageSourceKey = malloc(4)
let _displayRefreshFactorKey = malloc(4)
let _imageCountKey = malloc(4)
let _displayOrderKey = malloc(4)
let _imageSizeKey = malloc(4)
let _imageDataKey = malloc(4)

public let defaultLevelOfIntegrity: Float = 0.8

fileprivate enum GifParseError:Error {
    case noImages
    case noProperties
    case noGifDictionary
    case noTimingInfo
}

public extension UIImage {
    
    // MARK: Inits
    
    /**
     Convenience initializer. Creates a gif with its backing data.
     - Parameter gifData: The actual gif data
     - Parameter levelOfIntegrity: 0 to 1, 1 meaning no frame skipping
     */
    public convenience init(gifData:Data, levelOfIntegrity:Float = defaultLevelOfIntegrity) {
        self.init()
        setGifFromData(gifData,levelOfIntegrity: levelOfIntegrity)
    }
    
    /**
     Convenience initializer. Creates a gif with its backing data.
     - Parameter gifName: Filename
     - Parameter levelOfIntegrity: 0 to 1, 1 meaning no frame skipping
     */
    public convenience init(gifName: String, levelOfIntegrity: Float = defaultLevelOfIntegrity) {
        self.init()
        setGif(gifName, levelOfIntegrity: levelOfIntegrity)
    }
    
    /**
     Set backing data for this gif. Overwrites any existing data.
     - Parameter data: The actual gif data
     - Parameter levelOfIntegrity: 0 to 1, 1 meaning no frame skipping
     */
    public func setGifFromData(_ data:Data,levelOfIntegrity:Float) {
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil) else { return }
        self.imageSource = imageSource
        self.imageData = data

        do {
            calculateFrameDelay(try delayTimes(imageSource), levelOfIntegrity: levelOfIntegrity)
        } catch {
            print("Could not determine delay times for GIF.")
            return
        }
        calculateFrameSize()
    }
    
    /**
     Set backing data for this gif. Overwrites any existing data.
     - Parameter name: Filename
     */
    public func setGif(_ name: String) {
        setGif(name, levelOfIntegrity: defaultLevelOfIntegrity)
    }
    
    /**
     Check the number of frame for this gif
     - Return number of frames
     */
    public func framesCount() -> Int{
        if let orders = self.displayOrder{
            return orders.count
        }
        return 0
    }
    
    /**
     Set backing data for this gif. Overwrites any existing data.
     - Parameter name: Filename
     - Parameter levelOfIntegrity: 0 to 1, 1 meaning no frame skipping
     */
    public func setGif(_ name: String, levelOfIntegrity: Float) {
        if let url = Bundle.main.url(forResource: name,
                                     withExtension: name.getPathExtension() == "gif" ? "" : "gif") {
            if let data = try? Data(contentsOf: url) {
                setGifFromData(data,levelOfIntegrity: levelOfIntegrity)
            } else {
                print("Error : Invalid GIF data for \(name).gif")
            }
        } else {
            print("Error : Gif file \(name).gif not found")
        }
    }
    
    public func clear() {
        imageData = nil
        imageSource = nil
        displayOrder = nil
        imageCount = nil
        imageSize = nil
        displayRefreshFactor = nil
    }
    
    // MARK: Logic

    fileprivate func convertToDelay(_ pointer:UnsafeRawPointer?) -> Float? {
        if pointer == nil {
            return nil
        }
        let value = unsafeBitCast(pointer, to:AnyObject.self)
        return value.floatValue
    }

    /**
     Get delay times for each frames
     - Parameter imageSource: reference to the gif image source
     - Returns array of delays
     */
    fileprivate func delayTimes(_ imageSource:CGImageSource) throws ->[Float] {
        
        let imageCount = CGImageSourceGetCount(imageSource)
        guard imageCount > 0 else {
            throw GifParseError.noImages
        }
        var imageProperties = [CFDictionary]()
        for i in 0..<imageCount{
            if let dict = CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil) {
                imageProperties.append(dict)
            } else {
                throw GifParseError.noProperties
            }
        }
        
        let frameProperties = try imageProperties.map(){
            (dict:CFDictionary)->CFDictionary in
            let key = Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()
            let value = CFDictionaryGetValue(dict, key)
            if value == nil {
                throw GifParseError.noGifDictionary
            }
            return unsafeBitCast(value, to:CFDictionary.self)
        }
        
        let EPS:Float = 1e-6
        let frameDelays:[Float] = try frameProperties.map(){
            let unclampedKey = Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()
            let unclampedPointer:UnsafeRawPointer? = CFDictionaryGetValue($0, unclampedKey)
            if let value = convertToDelay(unclampedPointer), value >= EPS {
                return value
            }
            let clampedKey = Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()
            let clampedPointer:UnsafeRawPointer? = CFDictionaryGetValue($0, clampedKey)
            if let value = convertToDelay(clampedPointer) {
                return value
            }
            throw GifParseError.noTimingInfo
        }
        return frameDelays
    }
    
    /**
     Compute backing data for this gif
     - Parameter delaysArray: decoded delay times for this gif
     - Parameter levelOfIntegrity: 0 to 1, 1 meaning no frame skipping
     */
    fileprivate func calculateFrameDelay(_ delaysArray:[Float],levelOfIntegrity:Float){
        
        var delays = delaysArray
        
        //Factors send to CADisplayLink.frameInterval
        let displayRefreshFactors = [60,30,20,15,12,10,6,5,4,3,2,1]
        
        //maxFramePerSecond,default is 60
        let maxFramePerSecond = displayRefreshFactors[0]
        
        //frame numbers per second
        let displayRefreshRates = displayRefreshFactors.map{ maxFramePerSecond/$0 }
        
        //time interval per frame
        let displayRefreshDelayTime = displayRefreshRates.map{ 1.0/Float($0) }
        
        //caclulate the time when each frame should be displayed at(start at 0)
        for i in delays.indices.dropFirst() { delays[i] += delays[i-1] }
        
        //find the appropriate Factors then BREAK
        for (i, delayTime) in displayRefreshDelayTime.enumerated() {
            
            let displayPosition = delays.map { Int($0/delayTime) }
            
            var framelosecount: Float = 0
            for j in displayPosition.indices.dropFirst() {
                if displayPosition[j] == displayPosition[j-1] {
                    framelosecount += 1
                }
            }
            
            if displayPosition.first == 0 {
                framelosecount += 1
            }
            
            if framelosecount <= Float(displayPosition.count) * (1.0 - levelOfIntegrity)
                || i == displayRefreshDelayTime.count-1 {
                
                imageCount = displayPosition.last
                displayRefreshFactor = displayRefreshFactors[i]
                displayOrder = []
                var indexOfold = 0
                var indexOfnew = 1
                while indexOfnew <= imageCount
                    && indexOfold < displayPosition.count {
                    if indexOfnew <= displayPosition[indexOfold] {
                        displayOrder?.append(indexOfold)
                        indexOfnew += 1
                    } else {
                        indexOfold += 1
                    }
                }
                break
            }
        }
    }
    
    /**
     Compute frame size for this gif
     */
    fileprivate func calculateFrameSize(){
        guard let imageSource = imageSource else {
            return
        }
        guard let imageCount = imageCount else {
            return
        }
        guard let cgImage = CGImageSourceCreateImageAtIndex(imageSource,0,nil) else {
            return
        }
        let image = UIImage(cgImage:cgImage)
        imageSize = Int(image.size.height * image.size.width * 4) * imageCount / 1000000
    }
    
    // MARK: get / set associated values
    
    public var imageSource: CGImageSource? {
        get {
            let result = objc_getAssociatedObject(self, _imageSourceKey!)
            if result == nil {
                return nil
            }
            return (result as! CGImageSource)
        }
        set {
            objc_setAssociatedObject(self, _imageSourceKey!, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    public var displayRefreshFactor: Int?{
        get {
            return objc_getAssociatedObject(self, _displayRefreshFactorKey!) as? Int
        }
        set {
            objc_setAssociatedObject(self, _displayRefreshFactorKey!, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    public var imageSize: Int?{
        get {
            return objc_getAssociatedObject(self, _imageSizeKey!) as? Int
        }
        set {
            objc_setAssociatedObject(self, _imageSizeKey!, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    public var imageCount: Int?{
        get {
            return objc_getAssociatedObject(self, _imageCountKey!) as? Int
        }
        set {
            objc_setAssociatedObject(self, _imageCountKey!, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    public var displayOrder: [Int]?{
        get {
            return objc_getAssociatedObject(self, _displayOrderKey!) as? [Int]
        }
        set {
            objc_setAssociatedObject(self, _displayOrderKey!, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    public var imageData:Data? {
        get {
            let result = objc_getAssociatedObject(self, _imageDataKey!)
            if result == nil {
                return nil
            }
            return (result as? Data)
        }
        set {
            objc_setAssociatedObject(self, _imageDataKey!, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
}

extension String {
    func getPathExtension() -> String {
        return (self as NSString).pathExtension
    }
}
