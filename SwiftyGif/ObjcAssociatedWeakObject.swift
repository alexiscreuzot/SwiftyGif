//
//  ObjcAssociatedWeakObject.swift
//

import Foundation

func objc_getAssociatedWeakObject(_ object: AnyObject, _ key: UnsafeRawPointer) -> AnyObject? {
    let block: (() -> AnyObject?)? = objc_getAssociatedObject(object, key) as? (() -> AnyObject?)
    return block != nil ? block?() : nil
}

func objc_setAssociatedWeakObject(_ object: AnyObject, _ key: UnsafeRawPointer, _ value: AnyObject?) {
    weak var weakValue = value
    let block: (() -> AnyObject?)? = {
        return weakValue
    }
    objc_setAssociatedObject(object, key, block, .OBJC_ASSOCIATION_COPY)
}
