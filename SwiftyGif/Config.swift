//
//  Config.swift
//

import UIKit

public final class Config {
    
    public static var `default` = Config()
    
    private(set) var imageViews: [UIImageView] = []
    private(set) var memoryLimit: Int
    private(set) var totalGifSize: Int = 0
    private(set) var haveCache: Bool = true
    
    /// A configuration set.
    ///
    /// - Parameter memoryLimit: The number of Mb max for this manager
    public init(memoryLimit: Int = 50) {
        self.memoryLimit = memoryLimit
    }
    
    /// Add a new imageView to this manager if it doesn't exist
    /// - Parameter imageView: The UIImageView we're adding to this manager
    public func addImageView(_ imageView: UIImageView) -> Bool {
        if imageViews.contains(imageView) {
            return false
        }
        
        updateCacheSize(for: imageView, add: true)
        imageViews.append(imageView)
        Manager.shared.startTimerIfNeeded()
        
        return true
    }
    
    /// Delete an imageView from this manager if it exists
    /// - Parameter imageView: The UIImageView we want to delete
    public func deleteImageView(_ imageView: UIImageView) {
        guard let index = imageViews.firstIndex(of: imageView) else {
            return
        }
        
        imageViews.remove(at: index)
        updateCacheSize(for: imageView, add: false)
    }
    
    private func updateCacheSize(for imageView: UIImageView, add: Bool) {
        totalGifSize += (add ? 1 : -1) * (imageView.gifImage?.imageSize ?? 0)
        haveCache = totalGifSize <= memoryLimit
        imageViews.forEach { DispatchQueue.global(qos: .userInteractive).sync(execute: $0.updateCache) }
    }
    
    /// Check if this manager has cache for an imageView
    /// - Parameter imageView: The UIImageView we're searching cache for
    /// - Returns : a boolean for wether we have cache for the imageView
    func hasCache(_ imageView: UIImageView) -> Bool{
        return imageView.displaying && (imageView.loopCount == -1 || imageView.loopCount >= 5) ? haveCache : false
    }
}
