//
//  SwiftyGifTests.swift
//  SwiftyGifTests
//
//  Created by Alexis Creuzot on 28/03/16.
//  Copyright © 2016 alexiscreuzot. All rights reserved.
//

import XCTest
import SwiftyGif
import SnapshotTesting

extension XCTestCase {
//    func image(inTestBundleNamed name: String) -> UIImage {
//        return UIImage(contentsOfFile: urlForResource(inTestBundleNamed: name).path)!
//    }

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

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testThatNonAnimatedGIFCanBeLoaded() {
        // GIVEN
        let gifName = "single_frame_Zt2012.gif"
        var sut: UIImage!
        let data = self.data(filename: gifName)!

        // WHEN
        do {
            sut = try UIImage(gifData: data, levelOfIntegrity: 1)
        } catch let error {
            XCTFail(error.localizedDescription)
        }

        // THEN
        let reference = UIImage(data: data)

        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 640, height: 640)))
        imageView.setGifImage(sut)

        let gifImage = imageView.currentImage!
//        XCTAssertEqual(gifImage, reference)

        assertSnapshot(matching: gifImage, as: .image)
    }

    func testThatVeryBigGIFCanBeLoaded() {
        // GIVEN
        let gifName = "20000x20000"
        var sut: UIImage!

        // WHEN
        do {
            sut = try UIImage(gifName: gifName)
        } catch let error {
            XCTFail(error.localizedDescription)
        }

        // THEN
        let reference = UIImage(named: "20000x20000.gif")
        XCTAssertEqual(sut, reference)
    }

    func testThatGIFWithoutkCGImagePropertyGIFDictionaryCanBeLoaded() {
        // GIVEN
        let gifName = "not_animated"
        var sut: UIImage!

        // WHEN
        do {
            sut = try UIImage(gifName: gifName)
        } catch let error {
            XCTFail(error.localizedDescription)
        }

        // THEN
        let reference = UIImage(named: "not_animated.gif")
        XCTAssertEqual(sut, reference)
    }

    /*
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

 */
}
