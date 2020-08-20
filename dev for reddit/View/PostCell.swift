//
//  PostCell.swift
//  dev for reddit
//
//  Created by Noel Espino Córdova on 20/08/20.
//  Copyright © 2020 slingercode. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {

    @IBOutlet weak var subredditLabel: UILabel!
    @IBOutlet weak var postLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
