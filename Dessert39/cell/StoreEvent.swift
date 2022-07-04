//
//  StoreEvent.swift
//  Dessert39
//
//  Created by YongSoo Choi on 2021/12/13.
//

import UIKit

class StoreEvent: UITableViewCell {
    
    @IBOutlet var image_thum: UIImageView!{
        didSet{
            image_thum.layer.cornerRadius = 10
        }
    }
    @IBOutlet var label_name: UILabel!
    @IBOutlet var label_name_en: UILabel!
    @IBOutlet var label_price: UILabel!{
        didSet{
            label_price.text = ""
        }
    }
    @IBOutlet var label_event: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
