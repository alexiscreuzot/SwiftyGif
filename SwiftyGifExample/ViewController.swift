//
//  ViewController.swift
//  SwiftyGifManager
//

import UIKit
import SwiftyGif

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    let gifManager = SwiftyGifManager(memoryLimit:100)
    let images = [
                  "https://media.giphy.com/media/5tkEiBCurffluctzB7/giphy.gif",
                  "2.gif",
                  "https://media.giphy.com/media/5xtDarmOIekHPQSZEpq/giphy.gif",
                  "3.gif",
                  "https://media.giphy.com/media/3oEjHM2xehrp0lv6bC/giphy.gif",
                  "5.gif",
                  "https://media.giphy.com/media/l1J9qg0MqSZcQTuGk/giphy.gif",
                  "4.gif",
    ]

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailController = segue.destination as? DetailController {
            let indexPath = self.tableView.indexPathForSelectedRow
            detailController.path = images[indexPath!.row]
        }
    }

    // MARK: - TableView Datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! Cell

        if let image = try? UIImage(imageName: images[indexPath.row]) {
            cell.gifImageView.setImage(image, manager: gifManager, loopCount: -1)
        } else if let url = URL.init(string: images[indexPath.row]) {
            let loader = UIActivityIndicatorView.init(style: .white)
            cell.gifImageView.setGifFromURL(url, customLoader: loader)
        } else {
            cell.gifImageView.clear()
        }

        return cell
    }

    // MARK: - TableView Delegate

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }

}

