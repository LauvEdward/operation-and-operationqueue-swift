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
    override func prepareForReuse() {
        self.imageView?.image = nil
        self.descriptionLabel.text = ""
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setupUI(urlString: String, description: String) {
        self.imageShowView.image = CacheImage.shared.imageCache(forkey: urlString)
        descriptionLabel.text = description
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
