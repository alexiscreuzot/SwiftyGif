//
//  ViewController.swift
//  SwiftyGifManager
//

import UIKit

class ViewController: UIViewController {
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Inits
        let images = ["img1", "img2", "img3"]
        let nbImages = images.count
        let screenWidth = UIScreen.mainScreen().bounds.width
        let screenHeight = UIScreen.mainScreen().bounds.height  - 40
        
        // Manager
        let gifmanager = SwiftyGifManager(memoryLimit:40)
        
        for index in 0...nbImages-1 {

            // Create animated image
            let image = UIImage(gifName:images[index])

            // Create ImageView and add animated image
            let imageview = UIImageView(gifImage: image, manager:gifmanager,loopTime: -1)
            imageview.contentMode = .ScaleAspectFill
            imageview.clipsToBounds = true
            let imageHeight = (screenHeight / CGFloat(nbImages))
            imageview.frame = CGRect(x: 0.0, y: 40 + CGFloat(index) * imageHeight, width: screenWidth, height: imageHeight)
            self.view.addSubview(imageview)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
