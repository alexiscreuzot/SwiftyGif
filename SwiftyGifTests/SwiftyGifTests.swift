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

    var sut: UIImage!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }

    private func asset(gifName: String, file: StaticString = #file, testName: String = #function, line: UInt = #line) {
        // GIVEN
        let data = self.data(filename: gifName)!

        // WHEN
        do {
            sut = try UIImage(gifData: data)
        } catch let error {
            XCTFail(error.localizedDescription)
            return
        }

        // THEN
        let imageView = UIImageView()
        imageView.setGifImage(sut)

        // can not snapshot the UIImageView directly since it would produce nil image. Snapshot imageView.currentImage instead
        let gifImage = imageView.currentImage!
        assertSnapshot(matching: gifImage, as: .image, file: file, testName: testName, line: line)
    }

//    public func assertSnapshot<Value, Format>(matching value: @autoclosure () throws -> Value, as snapshotting: SnapshotTesting.Snapshotting<Value, Format>, named name: String? = nil, record recording: Bool = false, timeout: TimeInterval = 5, file: StaticString = #file, testName: String = #function, line: UInt = #line) {
//
//    }


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

    func testThat15MBGIFCanBeLoaded() {
        asset(gifName: "15MB_Einstein_rings_zoom.gif")
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
