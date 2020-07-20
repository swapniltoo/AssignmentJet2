//
//  SkTableViewCell.swift
//  AssignmentJet2
//
//  Created by Apple on 20/07/20.
//  Copyright © 2020 Apple. All rights reserved.
//

import UIKit

class SkTableViewCell: UITableViewCell {

    @IBOutlet var img  : UIImageView!
    @IBOutlet var mediaImg : UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var byline: UILabel!
    @IBOutlet weak var published_date: UILabel!

    override func prepareForReuse() {
        // invoke superclass implementation
        super.prepareForReuse()
        
        // reset (hide) the checkmark label
        self.mediaImg.isHidden = true

    }

    

    var cellData : [String:Any] = [:]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
