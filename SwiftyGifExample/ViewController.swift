//
//  ViewController.swift
//  SwiftyGifManager
//

import UIKit
import SwiftyGif

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    let gifManager = SwiftyGifManager(memoryLimit:100)
    let images = ["20000x20000", "Zt2012", "not_animated", "1", "2", "3", "5", "4"]

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailController = segue.destination as? DetailController {
            let indexPath = self.tableView.indexPathForSelectedRow
            detailController.gifName = images[indexPath!.row]
        }
    }

    // MARK: - TableView Datasource

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! Cell

        do {
            try cell.gifImageView.setGif(gifName: images[indexPath.row], gifManager: gifManager)
        } catch let error {
            print("Error : \(error.localizedDescription)")
        }

        return cell
    }

    // MARK: - TableView Delegate

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }

}


extension UIImageView {
    func setGif(gifName: String, gifManager: SwiftyGifManager) throws {

        do {
            let gifImage = try UIImage(gifName: gifName)
            setGifImage(gifImage, manager: gifManager, loopCount: -1)
        } catch {
            clear()

            gifManager.deleteImageView(self)

            if let gifImage = UIImage(named: "\(gifName).gif") {
                image = gifImage
            } else {
                throw MyGifParseError.retryUIImageInitFail
            }
        }
    }
}

enum MyGifParseError: Error {
    case retryUIImageInitFail
}
