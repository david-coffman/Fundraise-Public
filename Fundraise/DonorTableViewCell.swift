//
//  DonorTableViewCell.swift
//  Fundraise
//
//  Created by David Coffman on 12/29/19.
//  Copyright © 2019 David Coffman. All rights reserved.
//

import UIKit

class DonorTableViewCell: UITableViewCell {

    @IBOutlet var donorNameLabel: UILabel!
    @IBOutlet var contactImageLabel: UIImageView!
    @IBOutlet var donationImageLabel: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(name: String, hasBeenContacted: Bool, hasDonated: Bool) {
        donorNameLabel.text = name.capitalized
        contactImageLabel.image = hasBeenContacted ? UIImage(systemName: "person.crop.circle.badge.checkmark")! : UIImage(systemName: "person.crop.circle.badge.xmark")!
        contactImageLabel.tintColor = hasBeenContacted ? .systemGreen : .systemRed
        donationImageLabel.image = hasDonated ? UIImage(systemName: "checkmark.seal.fill")! : UIImage(systemName: "xmark.seal.fill")!
        donationImageLabel.tintColor = hasDonated ? .systemGreen : .systemRed
    }
}
