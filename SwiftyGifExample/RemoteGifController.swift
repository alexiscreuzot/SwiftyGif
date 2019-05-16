//
//  RemoteGifController.swift
//  SwiftyGifExample
//
//  Created by Alexis Creuzot on 14/02/2018.
//  Copyright © 2018 alexiscreuzot. All rights reserved.
//

import UIKit
import SwiftyGif

class RemoteGifController: UIViewController {
    
    @IBOutlet private weak var imageView: UIImageView!
    
    var gifName: String?
    let gifConfig = Config(memoryLimit: 60)
    
    let gifs = ["https://i.giphy.com/media/fSvqyvXn1M3btN8sDh/giphy.gif",
                "https://i.imgur.com/eZcQvpc.gif"]
    
    var currentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.delegate = self
        self.fetchGifFromURLString(gifs[currentIndex])
    }
    
    func fetchGifFromURLString(_ string: String?) {
        guard let string = string, let url = URL(string: string) else {
            return
        }
        
        self.imageView.setGifFromURL(url, config: gifConfig, levelOfIntegrity: .highestNoFrameSkipping)
    }
    
    @IBAction func selectNext() {
        currentIndex = (currentIndex + 1) % gifs.count
        self.fetchGifFromURLString(gifs[currentIndex])
    }
    
}

extension RemoteGifController : SwiftyGifDelegate {
    
    func gifURLDidFinish(sender: UIImageView) {
        print("gifURLDidFinish")
    }
    
    func gifURLDidFail(sender: UIImageView, url: URL, error: Error?) {
        print("gifURLDidFail", url)
        
        if let error = error {
            print(error)
        }
    }
    
    func gifDidStart(sender: UIImageView) {
        print("gifDidStart")
    }
}
