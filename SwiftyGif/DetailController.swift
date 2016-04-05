//
//  DetailController.swift
//  SwiftyGif
//
//  Created by Alexis Creuzot on 04/04/16.
//  Copyright © 2016 alexiscreuzot. All rights reserved.
//

import UIKit

class DetailController: UIViewController {

    @IBOutlet private weak var imageView: UIImageView!

    let gifManager = SwiftyGifManager(memoryLimit:30)
    var gifName = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        let gifImage = UIImage(gifName: self.gifName)
        self.imageView.setGifImage(gifImage, manager: gifManager, loopTime: -1)
    }

}
