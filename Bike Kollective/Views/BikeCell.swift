//
//  BikeCell.swift
//  Bike Kollective
//
//  Created by Born4Film on 1/25/22.
//

import UIKit

class BikeCell: UITableViewCell {

    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var picView: BikeImageView!
    @IBOutlet weak var ratingView: UIImageView!
    @IBOutlet weak var tagsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
