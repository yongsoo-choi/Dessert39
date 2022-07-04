//
//  StoreStarpoint.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/12/15.
//

import UIKit

class StoreStarpoint: UITableViewCell {

    @IBOutlet var labels: [UILabel]!
    @IBOutlet var progress: [UIProgressView]!
    
    @IBOutlet var label_total: UILabel!
    @IBOutlet var label_totalStarpoint: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

