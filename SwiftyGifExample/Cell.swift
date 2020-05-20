//
//  Cell.swift
//  SwiftyGif
//
//  Created by Alexis Creuzot on 04/04/16.
//  Copyright © 2016 alexiscreuzot. All rights reserved.
//

import UIKit

class Cell: UITableViewCell {

    @IBOutlet weak var gifImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.gifImageView.clear()
    }

}
