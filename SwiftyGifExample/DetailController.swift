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

    var gifName: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let imgName = self.gifName {
            let gifImage = UIImage(gifName: imgName)
            self.imageView.setGifImage(gifImage, manager: SwiftyGifManager.defaultManager, loopCount: -1)
        }

    }

}
