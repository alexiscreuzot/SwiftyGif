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
    let gifManager = SwiftyGifManager(memoryLimit:60)
    
    let gifs = ["https://i.imgur.com/bGmrLYl.gif",
                "https://i.imgur.com/vuDul3q.gif",
                "https://i.imgur.com/IEUz0rh.gif",
                "https://i.imgur.com/IhKa7F5.gif",
                "https://i.imgur.com/I3YiUBA.gif"]
    
    var currentIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.delegate = self
        self.fetchGifFromURLString(gifs[currentIndex])
    }
    
    func fetchGifFromURLString(_ string: String?) {
        guard let string = string else {
            return
        }
        let url = URL(string: string)
        self.imageView.setGifFromURL(url)
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
    
    func gifURLDidFail(sender: UIImageView) {
        print("gifURLDidFail")
    }
    
    func gifDidStart(sender: UIImageView) {
        print("gifDidStart")
    }
}
