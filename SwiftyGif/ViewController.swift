//
//  ViewController.swift
//  SwiftyGifManager
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    let gifManager = SwiftyGifManager(memoryLimit:60)
    let images = ["img1", "img2", "img3", "img4", "img5", "img6"]
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    // MARK: - TableView Datasource

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! Cell
        let gifImage = UIImage(gifName: images[indexPath.row % self.images.count])
        cell.gifImageView.setGifImage(gifImage, manager: gifManager, loopTime: -1)
        return cell
    }

    // MARK: - TableView Delegate

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 200
    }


    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let gifCell =  cell as? Cell {
            gifCell.gifImageView.startDisplay()
        }
    }

    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let gifCell =  cell as? Cell {
            gifCell.gifImageView.stopDisplay()
        }
    }
    
}
