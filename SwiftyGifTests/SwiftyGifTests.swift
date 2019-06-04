//
//  SwiftyGifTests.swift
//  SwiftyGifTests
//
//  Created by Bill, Chan Yiu Por on 03/06/19.
//  Copyright © 2019 BillChan. All rights reserved.
//

import XCTest
import SwiftyGif
import SnapshotTesting

extension XCTestCase {

    func data(filename: String) -> Data? {
        let data = try? Data(contentsOf: url(for: filename))

        return data
    }

    func url(for filename: String) -> URL {
        let bundle = Bundle(for: type(of: self))

        let url = bundle.url(forResource: filename, withExtension: "")

        if let isFileURL = url?.isFileURL {
            XCTAssert(isFileURL)
        } else {
            XCTFail("\(filename) does not exist")
        }

        return url!
    }
}

final class SwiftyGifTests: XCTestCase {

    var sut: UIImage!
    let gifManager = SwiftyGifManager(memoryLimit:100)

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }


    @discardableResult
    private func createImage(gifName: String, file: StaticString = #file, testName: String = #function, line: UInt = #line) -> UIImage! {
        let data = self.data(filename: gifName)!

        do {
            sut = try UIImage(imageData: data)
        } catch let error {
            XCTFail(error.localizedDescription)
            return nil
        }

        return sut
    }

    private func createImageView(gifName: String, gifManager: SwiftyGifManager = .defaultManager, file: StaticString = #file, testName: String = #function, line: UInt = #line) -> UIImageView! {

        createImage(gifName: gifName)

        if sut == nil {
            return nil
        }

        let imageView = UIImageView()
        imageView.setImage(sut, manager: gifManager)

        return imageView
    }

    private func asset(gifName: String, file: StaticString = #file, testName: String = #function, line: UInt = #line) {
        let imageView = createImageView(gifName: gifName)

        // can not snapshot the UIImageView directly since it would produce nil image. Snapshot imageView.currentImage instead
        let image: UIImage
        if let gifImage = imageView?.currentImage {
            image = gifImage
        } else {
            image = imageView!.image!
        }
        assertSnapshot(matching: image, as: .image, file: file, testName: testName, line: line)
    }

    func testThatNonAnimatedGIFCanBeLoadedWithUIImage() {
        // GIVEN
        let gifName = "single_frame_Zt2012.gif"
        let data = self.data(filename: gifName)!

        // WHEN
        sut = UIImage(data: data)

        // THEN

        let imageView = UIImageView(image: sut)

        assertSnapshot(matching: imageView, as: .image)
    }

    func testThatNonAnimatedGIFCanBeLoaded() {
        asset(gifName: "single_frame_Zt2012.gif")
    }

    func testThatVeryBigGIFCanBeLoaded() {
        asset(gifName: "20000x20000.gif")
    }

    func DISABLE_testThatVeryBigGIFCanBeLoaded() { ///TODO: used 18GB of memory and the output snapshot PNG is 31 MB
        // GIVEN
        let gifName = "20000x20000.gif"
        let data = self.data(filename: gifName)!

        // WHEN
        sut = UIImage(data: data)

        // THEN

        let imageView = UIImageView(image: sut)

        assertSnapshot(matching: imageView, as: .image)
    }

    func testThatGIFWithoutkCGImagePropertyGIFDictionaryCanBeLoaded() {
        asset(gifName: "no_property_dictionary.gif")
    }

    func testThatNonGifImageCanBeLoaded() {
        asset(gifName: "sample.jpg")
    }

    func testThat15MBGIFCanBeLoaded() {
        asset(gifName: "15MB_Einstein_rings_zoom.gif")
    }

    func testThatImageViewCanBeRecycledForGIF() {
        let data = self.data(filename: "sample.jpg")!

        let imageView = UIImageView()

        let normalImage = UIImage(data: data)!
        imageView.setImage(normalImage, manager: gifManager)
        imageView.frame = CGRect(origin: .zero, size: normalImage.size)


        XCTAssertFalse(gifManager.containsImageView(imageView))
        ///snapshot of the normal image
        assertSnapshot(matching: imageView, as: .image)

        createImage(gifName: "15MB_Einstein_rings_zoom.gif")
        imageView.setGifImage(sut, manager: gifManager)

        ///snapshot of the GIF
        assertSnapshot(matching: imageView.currentImage!, as: .image)

        ///snapshot of the normal image
        gifManager.deleteImageView(imageView)

        imageView.image = normalImage
        assertSnapshot(matching: imageView, as: .image)
    }

    /// GIF -> normal image recycling
    func testThatImageViewCanBeRecycledForNormalImage() {
        // GIVEN
        let imageView = createImageView(gifName: "15MB_Einstein_rings_zoom.gif", gifManager: gifManager)!

        ///snapshot of the GIF
        assertSnapshot(matching: imageView.currentImage!, as: .image)

        // WHEN
        let data = self.data(filename: "sample.jpg")!

        let updateImage = UIImage(data: data)!
        imageView.setImage(updateImage, manager: gifManager)
        imageView.frame = CGRect(origin: .zero, size: updateImage.size)

        // THEN
        XCTAssertFalse(gifManager.containsImageView(imageView))

        ///snapshot of the updated JPG
        assertSnapshot(matching: imageView, as: .image)

    }

}
