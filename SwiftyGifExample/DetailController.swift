//
//  DetailController.swift
//  SwiftyGif
//
//  Created by Alexis Creuzot on 04/04/16.
//  Copyright © 2016 alexiscreuzot. All rights reserved.
//

import UIKit
import SwiftyGif

class DetailController: UIViewController {

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var forwardButton: UIButton!
    @IBOutlet private weak var rewindButton: UIButton!

    var path: String?
    let gifManager = SwiftyGifManager(memoryLimit: 60)
    var _rewindTimer: Timer?
    var _forwardTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let path = self.path {
            if let image = try? UIImage(imageName: path) {
                self.imageView.setImage(image, manager: gifManager, loopCount: -1)
            } else if let url = URL.init(string: path) {
                let loader = UIActivityIndicatorView.init(style: .white)
                self.imageView.setGifFromURL(url, customLoader: loader)
            } else {
                self.imageView.clear()
            }
        }

        // Gestures for gif control
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panGesture))
        self.imageView.addGestureRecognizer(panGesture)
        self.imageView.isUserInteractionEnabled = true
        self.imageView.delegate = self

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.togglePlay))
        self.imageView.addGestureRecognizer(tapGesture)
    }

    // PRAGMA - Logic

    @objc func rewind(){
        self.imageView.showFrameForIndexDelta(-1)
    }

    @objc func forward(){
        self.imageView.showFrameForIndexDelta(1)
    }

    func stop(){
        self.imageView.stopAnimatingGif()
        self.playPauseButton.setTitle("►", for: .normal)
    }

    func play(){
        self.imageView.startAnimatingGif()
        self.playPauseButton.setTitle("❚❚", for: .normal)
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
        _rewindTimer = Timer.scheduledTimer(timeInterval: 1.0/30.0, target: self, selector: #selector(self.rewind), userInfo: nil, repeats: true)
    }

    @IBAction func rewindUp(){
        _rewindTimer?.invalidate()
        _rewindTimer = nil
    }

    @IBAction func forwardDown(){
        stop()
        _forwardTimer = Timer.scheduledTimer(timeInterval: 1.0/30.0, target: self, selector: #selector(self.forward), userInfo: nil, repeats: true)
    }

    @IBAction func forwardUp(){
        _forwardTimer?.invalidate()
        _forwardTimer = nil
    }

    // PRAGMA - Gestures

    @objc func panGesture(sender:UIPanGestureRecognizer){

        switch sender.state {
        case .began:
            stop()
            break

        case .changed:
            if sender.velocity(in: sender.view).x > 0 {
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

extension DetailController : SwiftyGifDelegate {

    func gifDidStart(sender: UIImageView) {
        print("gifDidStart")
    }
    
    func gifDidLoop(sender: UIImageView) {
        print("gifDidLoop")
    }
    
    func gifDidStop(sender: UIImageView) {
        print("gifDidStop")
    }
}
