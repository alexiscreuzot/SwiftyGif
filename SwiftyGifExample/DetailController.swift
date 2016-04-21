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
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var forwardButton: UIButton!
    @IBOutlet private weak var rewindButton: UIButton!

    var gifName: String?
    let gifManager = SwiftyGifManager(memoryLimit:60)
    var _rewindTimer: NSTimer?
    var _forwardTimer: NSTimer?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let imgName = self.gifName {
            let gifImage = UIImage(gifName: imgName)
            self.imageView.setGifImage(gifImage, manager: gifManager, loopCount: -1)
        }

        // Gestures for gif control
        let panGesture = UIPanGestureRecognizer.init(target: self, action: #selector(self.panGesture))
        self.imageView.addGestureRecognizer(panGesture)
        self.imageView.userInteractionEnabled = true

        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(self.togglePlay))
        self.imageView.addGestureRecognizer(tapGesture)
    }

    // PRAGMA - Logic

    func rewind(){
        self.imageView.showFrameForIndexDelta(-1)
    }

    func forward(){
        self.imageView.showFrameForIndexDelta(1)
    }

    func stop(){
        self.imageView.stopAnimatingGif()
        self.playPauseButton.setTitle("►", forState: .Normal)
    }

    func play(){
        self.imageView.startAnimatingGif()
        self.playPauseButton.setTitle("❚❚", forState: .Normal)
    }

    // PRAGMA - Actions

    @IBAction func togglePlay(){
        if self.imageView.isAnimatingGif() {
            stop()
        }else {
            play()
        }
    }

    @IBAction func rewindDown(){
        stop()
        _rewindTimer = NSTimer.scheduledTimerWithTimeInterval(1.0/30.0, target: self, selector: #selector(self.rewind), userInfo: nil, repeats: true)
    }

    @IBAction func rewindUp(){
        _rewindTimer?.invalidate()
        _rewindTimer = nil
    }

    @IBAction func forwardDown(){
        stop()
        _forwardTimer = NSTimer.scheduledTimerWithTimeInterval(1.0/30.0, target: self, selector: #selector(self.forward), userInfo: nil, repeats: true)
    }

    @IBAction func forwardUp(){
        _forwardTimer?.invalidate()
        _forwardTimer = nil
    }

    // PRAGMA - Gestures

    func panGesture(sender:UIPanGestureRecognizer){

        switch sender.state {
        case .Began:
            stop()
            break

        case .Changed:
            if sender.velocityInView(sender.view).x > 0 {
                forward()
            } else{
                rewind()
            }
            break

        default:
            break
        }
    }


}
