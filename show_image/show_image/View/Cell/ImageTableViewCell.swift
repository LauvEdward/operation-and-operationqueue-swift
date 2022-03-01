//
//  ImageTableViewCell.swift
//  show_image
//
//  Created by shogo harada on 01/03/2022.
//

import UIKit

class ImageTableViewCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageShowView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupUI(image: UIImage, description: String) {
        imageShowView.image = image
        descriptionLabel.text = description
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
